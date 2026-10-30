import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> loginWithEmailPassword(String email, String password);
  Future<UserEntity> registerWithEmailPassword(String email, String password);
  Future<UserEntity> loginWithGoogle();
  Future<void> linkGoogleAccount();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
  Future<void> deleteAccount();
}
