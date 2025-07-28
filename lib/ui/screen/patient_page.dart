// lib/screens/patient_home.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikars/ui/theme/colors.dart';
import '../../models/room_model.dart';
import '../../models/user_model.dart';
import '../../service/auth_service.dart';
import 'login_page.dart';

class PatientPage extends StatelessWidget {
  final UserModel user;

  PatientPage({required this.user});

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        title: Text("Pasien - ${user.name}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => logout(context), icon: Icon(Icons.logout, color: Colors.white))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = RoomModel.fromMap(docs[index].id, docs[index].data() as Map<String, dynamic>);
              return ListTile(
                title: Text(data.name),
                subtitle: Row(
                  children: [
                    Text("Status: "),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(data.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data.status,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "tersedia":
        return Colors.green;
      case "terisi":
        return Colors.red;
      case "dibersihkan":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

}
