import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resky/core/constants/constants.dart';
import 'package:resky/core/constants/firebase_constants.dart';
import 'package:resky/core/failure.dart';
import 'package:resky/core/providers/firebase_providers.dart';
import 'package:resky/core/type_defs.dart';
import 'package:resky/models/user_model.dart';
import 'package:fpdart/fpdart.dart';


final authRepositoryProvider = Provider((ref)=> AuthRepository(firestore: ref.read(firestoreProvider), auth: ref.read(authProvider), googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth, 
    required GoogleSignIn googleSignIn
    }) : _auth = auth, _firestore = firestore, _googleSignIn = googleSignIn;
  
  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return left(Failure('Google sign-in aborted.'));
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: (await googleUser.authentication)?.accessToken,
      idToken: (await googleUser.authentication)?.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);

    UserModel userModel;

    if (userCredential.additionalUserInfo!.isNewUser) {
      userModel = UserModel(
        name: userCredential.user!.displayName ?? 'No Name',
        propic: userCredential.user!.photoURL ?? Constants.avatarDefault,
        probanner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAdmin: false,
        email: userCredential.user!.email,
        role: null,
      );
      await _users.doc(userCredential.user!.uid).set(userModel.toMap());
    } else {
      userModel = await getUserData(userCredential.user!.uid).first;
    }

    return right(userModel);
  } on FirebaseException catch (e) {
    return left(Failure(e.message ?? 'Firebase error occurred.'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}



  Stream<UserModel> getUserData(String uid){
    return _users.doc(uid).snapshots().map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

    //logout

    void logOut() async{
      await _googleSignIn.signOut();
      await _auth.signOut();
    }

}