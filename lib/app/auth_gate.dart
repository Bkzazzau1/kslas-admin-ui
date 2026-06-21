import 'package:flutter/material.dart';

import '../core/auth/auth_session.dart';
import '../features/auth/widgets/staff_login_screen.dart';
import 'connected_admin_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthSession.instance,
      builder: (context, _) {
        if (AuthSession.instance.isSignedIn) {
          return const ConnectedAdminHome();
        }
        return const StaffLoginScreen();
      },
    );
  }
}
