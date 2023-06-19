import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/helper_function.dart';
import 'package:we_chat/pages/auth/login_page.dart';
import 'package:we_chat/pages/profile_page.dart';
import 'package:we_chat/pages/search_page.dart';
import 'package:we_chat/service/auth_services.dart';
import 'package:we_chat/service/database_service.dart';
import 'package:we_chat/widgets/group_tile.dart';
import 'package:we_chat/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  String userName = "";
  String email = "";
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";


  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  //string manipulation
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }
  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) => {
          setState(() {
            email = value!;
          })
        });
    await HelperFunctions.getUserNameFromSF().then((value) => {
          setState(() {
            userName = value!;
          })
        });
    //getting the list of snapshot in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot){
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, const SearchPage());
            },
            icon: const Icon(Icons.search_rounded),
          )
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Groups",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                    context,
                    ProfilePage(
                      email: email,
                      userName: userName,
                    ));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app_sharp),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(onPressed: () {
        popUpDialog(context);
      },
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add,
      color: Colors.white,size: 30,),
      ),
    );
  }

  popUpDialog(BuildContext context){
    showDialog(barrierDismissible: false,context: context, builder: (context){
         return StatefulBuilder(
           builder: ((context, setState){
          return  AlertDialog(
            title: const Text("Create a group",
              textAlign: TextAlign.left,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),)
                    :TextField(
                  onChanged: (val){
                    setState(() {
                      groupName = val;
                    });
                  },
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: const Text("Cancel",),
              ),
              ElevatedButton(onPressed: () async {
                if(groupName!=""){
                  setState(() {
                    _isLoading = true;
                  });
                  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).
                  createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName)
                      .whenComplete(() =>
                  {_isLoading = false});
                  Navigator.of(context).pop();
                  showSnackbar(context, Colors.green,const Text("Group created successfully",style: TextStyle(color: Colors.black),));
                }
              },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: const Text("Create"),
              )
            ],
          );
           })
        );
    });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder:(context, AsyncSnapshot snapshot){
        //checks
        if(snapshot.hasData){
          if(snapshot.data['groups'] != null){
                if(snapshot.data['groups'].length != 0){
                    return ListView.builder(
                      itemCount: snapshot.data['groups'].length,
                      itemBuilder: (context,index){
                        // reverseIndex in this case is for displaying the recent group on the top
                        int reverseIndex = snapshot.data['groups'].length - index - 1;
                        return GroupTile(
                            groupName: getName(snapshot.data['groups'][reverseIndex]),
                            groupId: getId(snapshot.data['groups'][reverseIndex]),
                            userName: snapshot.data['fullName']);
                      },
                    );
                }else{
                  return noGroupWidget();
                }
          }else{
            return noGroupWidget();
          }
        }
        else{
          return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),);
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
