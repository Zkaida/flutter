import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/app_router.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/bloc/category/category_cubit.dart';
import 'package:flutter_foodstore/bloc/checkout/checkout_cubit.dart';
import 'package:flutter_foodstore/bloc/location/location_cubit.dart';
import 'package:flutter_foodstore/bloc/order/order_cubit.dart';
import 'package:flutter_foodstore/bloc/product/product_cubit.dart';
import 'package:flutter_foodstore/bloc/product_populer/product_populer_cubit.dart';
import 'package:flutter_foodstore/bloc/profile/profile_bloc.dart';
import 'package:flutter_foodstore/bloc/review_product/review_product_cubit.dart';
import 'package:flutter_foodstore/bloc/shipping_cost/shipping_cost_cubit.dart';
import 'package:flutter_foodstore/bloc/slider/slider_cubit.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/auth_interceptor.dart';
import 'package:flutter_foodstore/resource/remote/auth_remote_resource.dart';
import 'package:flutter_foodstore/resource/remote/cart_remote_resource.dart';
import 'package:flutter_foodstore/resource/remote/checkout_remote_resource.dart';
import 'package:flutter_foodstore/resource/remote/home_remote_resource.dart';
import 'package:flutter_foodstore/resource/remote/order_remote_resource.dart';
import 'package:flutter_foodstore/resource/remote/profile_remote_resource.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio(BaseOptions(baseUrl: AppConfig.API_PATH, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)));
  final authBloc = AuthBloc(AuthRemoteResource(dio))..add(const AuthCheckLoginStatus());
  dio.interceptors.add(AuthInterceptor(authBloc));

  final homeRemote = HomeRemoteResource(dio);
  final cartRemote = CartRemoteResource(dio);
  final orderRemote = OrderRemoteResource(dio);
  final checkoutRemote = CheckoutRemoteResource(dio);
  final profileRemote = ProfileRemoteResource(dio);

  runApp(MyApp(
    authBloc: authBloc,
    homeRemote: homeRemote,
    cartRemote: cartRemote,
    orderRemote: orderRemote,
    checkoutRemote: checkoutRemote,
    profileRemote: profileRemote,
  ));
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final HomeRemoteResource homeRemote;
  final CartRemoteResource cartRemote;
  final OrderRemoteResource orderRemote;
  final CheckoutRemoteResource checkoutRemote;
  final ProfileRemoteResource profileRemote;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.homeRemote,
    required this.cartRemote,
    required this.orderRemote,
    required this.checkoutRemote,
    required this.profileRemote,
  });

  @override
  Widget build(BuildContext context) {
    final router = createRouter(authBloc);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (_) => ProfileBloc(profileRemote)),
        BlocProvider(create: (_) => SliderCubit(homeRemote)),
        BlocProvider(create: (_) => CategoryCubit(homeRemote)),
        BlocProvider(create: (_) => ProductCubit(homeRemote)),
        BlocProvider(create: (_) => ProductPopulerCubit(homeRemote)),
        BlocProvider(create: (_) => CartBloc(cartRemote)),
        BlocProvider(create: (_) => OrderCubit(orderRemote)),
        BlocProvider(create: (_) => ReviewProductCubit(orderRemote)),
        BlocProvider(create: (_) => CheckoutCubit(checkoutRemote)),
        BlocProvider(create: (_) => ShippingCostCubit(checkoutRemote)),
        BlocProvider(create: (_) => LocationCubit(checkoutRemote)),
      ],
      child: MaterialApp.router(
        title: 'FoodStore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true),
        routerConfig: router,
      ),
    );
  }
}
