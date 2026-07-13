import '../models/app_user.dart';

class MockAuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser> login({
    required String name,
    required String registrationNumber,
    required UserRole role,
  }) async {
    // Simulates network latency
    await Future.delayed(const Duration(milliseconds: 350));

    _currentUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      registrationNumber: registrationNumber.trim().toUpperCase(),
      role: role,
    );
    return _currentUser!;
  }

  void logout() {
    _currentUser = null;
  }
}