import 'package:flutter/material.dart';
import '../../session/screens/lecturer_dashboard_screen.dart';
import '../../session/screens/student_join_screen.dart';
import '../models/app_user.dart';
import '../services/mock_auth_service.dart';
import '../widgets/role_selector_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regController = TextEditingController();
  final _authService = MockAuthService();

  UserRole _selectedRole = UserRole.student;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = await _authService.login(
      name: _nameController.text,
      registrationNumber: _selectedRole == UserRole.student
          ? _regController.text
          : 'STAFF',
      role: _selectedRole,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    final nextScreen = user.role == UserRole.lecturer
        ? LecturerDashboardScreen(user: user)
        : StudentJoinScreen(user: user);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.how_to_vote_rounded,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ClassPulse',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Live Attendance & Classroom Polls',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 28),
                    RoleSelectorCard(
                      role: UserRole.student,
                      title: 'Student',
                      subtitle: 'Join with a class code & vote in live polls',
                      icon: Icons.school_rounded,
                      isSelected: _selectedRole == UserRole.student,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.student),
                    ),
                    const SizedBox(height: 12),
                    RoleSelectorCard(
                      role: UserRole.lecturer,
                      title: 'Lecturer / Host',
                      subtitle: 'Start attendance sessions & launch polls',
                      icon: Icons.co_present_rounded,
                      isSelected: _selectedRole == UserRole.lecturer,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.lecturer),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'e.g. David Kamau',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    if (_selectedRole == UserRole.student) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _regController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Registration / Student ID',
                          hintText: 'e.g. CS/0142/24',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                                ? 'Enter your student ID'
                                : null,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}