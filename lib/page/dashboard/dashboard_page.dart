import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  final Widget child;
  const DashboardPage({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/order')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: GestureDetector(
          onTap: () => context.push('/search'),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Text('Cari makanan favoritmu...', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Logout',
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go('/');
                  },
                );
              }
              return TextButton(
                onPressed: () => context.push('/login'),
                child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/'); break;
            case 1: context.go('/order'); break;
            case 2: context.go('/cart'); break;
            case 3: context.go('/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'My Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
