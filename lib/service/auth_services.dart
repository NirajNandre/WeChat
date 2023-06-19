import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:we_chat/helper/helper_function.dart';
import 'package:we_chat/service/database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //login
  Future loginUserwithEmailandPassword(String email, String password) async{
    try{
      User user = (await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password))
          .user!;

      if(user!=null){

        return true;
      }
    }on FirebaseAuthException catch(e){
      return e.message;

    }
  }

  //register
  Future registerUserwithEmailandPassword(String fullName,String email, String password) async{
    try{
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user!;

      if(user!=null){
        //call our database service to update the user data
        DatabaseService(uid: user.uid).savingUserData(fullName, email);
        return true;
      }
    }on FirebaseAuthException catch(e){
      return e.message;

    }
  }
  //signout
  Future signOut() async {
    try{
      await HelperFunctions.savedUserLoggedInStatus(false);
      await HelperFunctions.savedUserEmailSF("");
      await HelperFunctions.savedUserNameSF("");
      await firebaseAuth.signOut();
    }catch(e){
      return null;
    }
  }
}