import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/browse/user_detail_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/sessions/request_session_screen.dart';
import '../features/shell/main_shell.dart';
import '../services/auth_service.dart';

/// Navigation + auto-redirects based on login state.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthNotifier(),
    redirect: (context, state) {
      final loggedIn = AuthService.instance.isLoggedIn;
      final goingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!loggedIn && !goingToAuth) return '/login';
      if (loggedIn && goingToAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const MainShell()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (_, state) =>
            UserDetailScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/request/:id',
        builder: (_, state) => RequestSessionScreen(
          teacherId: state.pathParameters['id']!,
          teacherName: (state.extra as String?) ?? 'this teacher',
        ),
      ),
    ],
  );
}

/// Bridges Supabase's auth stream into something GoRouter can listen to.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
