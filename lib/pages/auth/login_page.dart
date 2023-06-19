import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/helper_function.dart';
import 'package:we_chat/pages/auth/Register_page.dart';
import 'package:we_chat/pages/home_page.dart';
import 'package:we_chat/service/auth_services.dart';
import 'package:we_chat/service/database_service.dart';
import 'package:we_chat/shared/constants.dart';
import 'package:we_chat/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),):SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "We Chat",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login now For a Group Chat ! 😊",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Image.asset("assets/images/Login_image.png"),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Theme.of(context).primaryColor,
                    ), ),
                  onChanged: (val){
                    setState(() {
                      email = val;
                    });
                  },
                  validator: (val) {
                    return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(val!)
                        ? null
                        : "Please enter a valid email";
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  obscureText: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Theme.of(context).primaryColor,
                    ),),
                  validator: (val){
                    if(val!.length < 6){
                      return "Password must be at least 6 characters";
                    }else{
                      return null;
                    }
                  },
                  onChanged: (val){
                    setState(() {
                      password = val;
                    });
                  },
                ),
                SizedBox(height: 20,),
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(

                     style: ElevatedButton.styleFrom(
                       backgroundColor: Theme.of(context).primaryColor,
                       elevation: 4,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30)
                       )

                     ),
                       onPressed: (){
                       login();
                       },
                       child: const Text("Login", style: TextStyle(
                         color: Colors.white,
                         fontSize: 16,
                       ),)),
                 ),
                const SizedBox(height: 10,),
                Text.rich(
                  TextSpan(
                    text: "Don't have an account?",
                    style: const TextStyle(color: Colors.black,fontSize:14 ),
                    children: <TextSpan>[
                      TextSpan(
                        text:" Register Now",
                        style: TextStyle(
                          color: Constants().primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = (){
                          nextScreen(context, const RegisterPage());
                        }),
                    ],
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.loginUserwithEmailandPassword(
          email, password).then((value) async {
        if (value == true) {
           QuerySnapshot snapshot =  await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .gettingUserData(email);
           //saving the value to our shared preferences
           await HelperFunctions.savedUserLoggedInStatus(true);
           await HelperFunctions.savedUserEmailSF(email);
           await HelperFunctions.savedUserNameSF(snapshot.docs[0]['fullName']);
           nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
