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

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email atau password yang Anda masukkan salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau login.';
      case 'weak-password':
        return 'Password terlalu lemah. Silakan gunakan kombinasi yang lebih kuat.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan. Silakan hubungi admin.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
      default:
        return 'Terjadi kesalahan sistem (${e.code}). Silakan coba lagi.';
    }
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
      throw Exception('Gagal mendapatkan data pengguna setelah login.');
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      throw Exception('Login gagal. Silakan coba lagi.');
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
      throw Exception('Gagal mendapatkan data pengguna setelah registrasi.');
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      throw Exception('Registrasi gagal. Silakan coba lagi.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await firebaseAuth.signOut();
    } catch (e) {
      // Ignored or handle specifically
      throw Exception('Gagal logout. Silakan coba lagi.');
    }
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login Google dibatalkan oleh pengguna.');
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
      throw Exception('Gagal mendapatkan data pengguna setelah Login Google.');
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      throw Exception('Login Google gagal. Silakan coba lagi.');
    }
  }
}
