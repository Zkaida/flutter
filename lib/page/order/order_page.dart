import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/order/order_cubit.dart';
import 'package:flutter_foodstore/core/components/order_card.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchOrders(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderCubit>().fetchOrders(page: 1),
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) return const Center(child: CircularProgressIndicator());
          if (state is OrderLoaded) {
            if (state.orders.isEmpty) {
              return ListView(children: const [SizedBox(height: 180), Center(child: Text('Belum ada riwayat pesanan'))]);
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.orders.length + (state.currentPage < state.lastPage ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == state.orders.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: state.isLoadingMore ? null : () => context.read<OrderCubit>().fetchOrders(page: state.currentPage + 1, loadMore: true),
                      child: const Text('Load More'),
                    ),
                  );
                }
                return OrderCard(order: state.orders[i]);
              },
            );
          }
          if (state is OrderError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
