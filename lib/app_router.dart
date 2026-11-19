import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/page/auth/login_page.dart';
import 'package:flutter_foodstore/page/auth/register_page.dart';
import 'package:flutter_foodstore/page/cart/cart_page.dart';
import 'package:flutter_foodstore/page/checkout/checkout_page.dart';
import 'package:flutter_foodstore/page/checkout/midtrans_payment_page.dart';
import 'package:flutter_foodstore/page/dashboard/dashboard_page.dart';
import 'package:flutter_foodstore/page/home/home_page.dart';
import 'package:flutter_foodstore/page/home/search_page.dart';
import 'package:flutter_foodstore/page/order/order_detail_page.dart';
import 'package:flutter_foodstore/page/order/order_page.dart';
import 'package:flutter_foodstore/page/product/all_product_page.dart';
import 'package:flutter_foodstore/page/product/detail_product_page.dart';
import 'package:flutter_foodstore/page/product/product_by_category_page.dart';
import 'package:flutter_foodstore/page/profile/profile_page.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = context.read<AuthBloc>().state is AuthAuthenticated;
      final protectedRoutes = ['/order', '/cart', '/profile', '/checkout'];
      final isProtected = protectedRoutes.any((r) => state.matchedLocation.startsWith(r));
      if (!isLoggedIn && isProtected) return '/login';
      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => DashboardPage(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
          GoRoute(path: '/order', builder: (_, __) => const OrderPage()),
          GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
      GoRoute(path: '/allProduct', builder: (_, __) => const AllProductPage()),
      GoRoute(path: '/productByCategory/:slug', builder: (_, state) => ProductByCategoryPage(slug: state.pathParameters['slug'] ?? '')),
      GoRoute(path: '/detailProduct/:slug', builder: (_, state) => DetailProductPage(slug: state.pathParameters['slug'] ?? '')),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutPage()),
      GoRoute(path: '/midtransPayment/:snapToken', builder: (_, state) => MidtransPaymentPage(snapToken: state.pathParameters['snapToken'] ?? '')),
      GoRoute(path: '/orderDetail/:snapToken', builder: (_, state) => OrderDetailPage(snapToken: state.pathParameters['snapToken'] ?? '')),
    ],
  );
}
