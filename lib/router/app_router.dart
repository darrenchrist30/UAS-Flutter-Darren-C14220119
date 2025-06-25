import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../screens/get_started_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        final authProvider = context.read<AuthProvider>();

        // Check if it's the first time opening the app
        final isFirstTime = await authProvider.isFirstTimeOpened();
        if (isFirstTime && state.fullPath != '/get-started') {
          return '/get-started';
        }

        // Check authentication status
        final isLoggedIn = await authProvider.isLoggedIn();
        final isAuthenticated = authProvider.isAuthenticated;

        // If user is authenticated and trying to access auth pages, redirect to home
        if ((isLoggedIn || isAuthenticated) &&
            (state.fullPath == '/login' ||
                state.fullPath == '/signup' ||
                state.fullPath == '/get-started')) {
          return '/home';
        }

        // If user is not authenticated and trying to access protected pages, redirect to login
        if (!(isLoggedIn || isAuthenticated) &&
            (state.fullPath == '/home' || state.fullPath == '/')) {
          return '/login';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'root',
          redirect: (context, state) => '/login',
        ),
        GoRoute(
          path: '/get-started',
          name: 'get-started',
          builder: (context, state) => const GetStartedScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) {
            // Initialize tasks when entering home
            final authProvider = context.read<AuthProvider>();
            if (authProvider.user != null) {
              Future.microtask(() {
                context.read<TaskProvider>().initializeTasksForUser(
                  authProvider.user!.id,
                );
              });
            }
            return const HomeScreen();
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
