import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class UserRepository {
  final FirebaseAuth _fAuth;
  final FacebookLogin _facebookSignIn;

  UserRepository({FirebaseAuth firebaseAuth, FacebookLogin facebookSignIn})
      : _fAuth = firebaseAuth ?? FirebaseAuth.instance,
        _facebookSignIn = facebookSignIn ?? FacebookLogin();

  Future<FirebaseUser> signInWithFacebook() async {
    final FacebookLoginResult facebookUser = await _facebookSignIn
        .logInWithReadPermissions(['email', 'public_profile']);
    FacebookAccessToken myToken = facebookUser.accessToken;
    AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: myToken.token);
    await _fAuth.signInWithCredential(credential);
    return _fAuth.currentUser();
  }

  Future<void> signInWithCredentials(String email, String password) {
    return _fAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({String email, String password}) async {
    return await _fAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return Future.wait([
      _fAuth.signOut(),
      _facebookSignIn.logOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _fAuth.currentUser();
    return currentUser != null;
  }

  Future<FirebaseUser> getUser() async {
    return (await _fAuth.currentUser());
  }
}
