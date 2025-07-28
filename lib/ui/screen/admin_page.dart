import 'package:flutter/material.dart';
import 'package:sikars/service/auth_service.dart';
import 'package:sikars/ui/theme/colors.dart';
import '../../models/room_model.dart';
import '../../models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class AdminPage extends StatelessWidget {
  final UserModel user;

  AdminPage({required this.user});

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void updateStatus(String id, String newStatus) {
    FirebaseFirestore.instance.collection('rooms').doc(id).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        title: Text("Admin - ${user.name}" ,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => logout(context), icon: Icon(Icons.logout), color: Colors.white)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label "Daftar Pengguna"
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 8, top: 8),
              child: Text(
                "Daftar Kamar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // StreamBuilder untuk List Room
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = RoomModel.fromMap(docs[index].id, docs[index].data() as Map<String, dynamic>);
                    return ListTile(
                      title: Text(data.name),
                      subtitle: Row(
                        children: [
                          Text("Status: "),
                          SizedBox(width: 10),
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
                      trailing: DropdownButton<String>(
                        value: data.status,
                        items: ['tersedia', 'terisi', 'dibersihkan'].map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) updateStatus(data.id, newStatus);
                        },
                      ),
                    );
                  },
                );
              },
            ),

            // Label "Daftar Pengguna"
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 8, top: 8),
              child: Text(
                "Daftar Pengguna",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // StreamBuilder untuk Users
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final users = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;

                    return ListTile(
                      title: Text(userData['name'] ?? 'No Name'),
                      subtitle: Text(userData['email'] ?? 'No Email'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditUserDialog(context, userId, userData);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addRoom',
            onPressed: () => _showAddRoomDialog(context),
            label: Text("Add Room", style: TextStyle(color: Colors.white)),
            icon: Icon(Icons.meeting_room, color: Colors.white),
            backgroundColor: appColor,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'addUser',
            onPressed: () => _showAddUserDialog(context),
            label: Text("Add User", style: TextStyle(color: Colors.white)),
            icon: Icon(Icons.person_add, color: Colors.white),
            backgroundColor: appColor,
          ),
        ],
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

  void _showAddRoomDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Room"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "Room Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('rooms').add({
                'name': nameController.text,
                'status': 'tersedia',
              });
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').add({
                'name': nameController.text,
                'email': emailController.text,
                'password': passwordController.text,
                'role': 'user', // default role
              });
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, String id, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final emailController = TextEditingController(text: data['email']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Pengguna"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(id).update({
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

}

