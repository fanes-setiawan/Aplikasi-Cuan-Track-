import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepositoryImpl(this.firebaseAuth);

  UserEntity? _mapFirebaseUserToUserEntity(User? user) {
    if (user == null) return null;
    return UserEntity(uid: user.uid, email: user.email, name: user.displayName);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _mapFirebaseUserToUserEntity(firebaseAuth.currentUser);
  }

  @override
  Future<UserEntity> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _mapFirebaseUserToUserEntity(userCredential.user);
      if (user != null) return user;
      throw Exception('Failed to get user after login');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _mapFirebaseUserToUserEntity(userCredential.user);
      if (user != null) return user;
      throw Exception('Failed to get user after registration');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in canceled by user');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final user = _mapFirebaseUserToUserEntity(userCredential.user);
      if (user != null) return user;
      throw Exception('Failed to get user after Google login');
    } catch (e) {
      throw Exception('Google Login failed: ${e.toString()}');
    }
  }
}
