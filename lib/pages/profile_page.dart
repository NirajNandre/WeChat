import 'package:flutter/material.dart';
import 'package:we_chat/pages/auth/login_page.dart';
import 'package:we_chat/pages/home_page.dart';
import 'package:we_chat/service/auth_services.dart';
import 'package:we_chat/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key, required this.email, required this.userName}) : super(key: key);
  String  userName;
  String  email;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text("Profile",style: TextStyle(color:Colors.white,fontSize: 27, fontWeight: FontWeight.bold),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 15,),
            Text(
              widget.userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: () {
                nextScreen(context, const HomePage());
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.account_box),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                      (route) => false);
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app_sharp),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.account_circle, size: 200, color: Colors.grey[700],),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Full Name :", style: TextStyle(fontSize: 17),),
                Text(widget.userName, style: const  TextStyle(fontSize: 17),)

              ],
            ),
            const Divider(height: 20,color: Colors.grey,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Email :", style: TextStyle(fontSize: 17),),
                Text(widget.email, style: const  TextStyle(fontSize: 17),)

              ],
            ),
          ],
        ),
      ),
    );
  }
}
