import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/order/order_cubit.dart';
import 'package:flutter_foodstore/bloc/review_product/review_product_cubit.dart';
import 'package:flutter_foodstore/core/utils/currency_helper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends StatefulWidget {
  final String snapToken;
  const OrderDetailPage({super.key, required this.snapToken});
  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().detailOrder(widget.snapToken);
  }

  void _showReviewDialog(int transactionDetailId, int productId, String productTitle) {
    int selectedRating = 5;
    final reviewController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ulas $productTitle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              itemCount: 5,
              itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (val) => selectedRating = val.toInt(),
            ),
            const SizedBox(height: 12),
            TextField(controller: reviewController, maxLines: 3, decoration: const InputDecoration(hintText: 'Tulis pengalamanmu...', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            onPressed: () {
              context.read<ReviewProductCubit>().submitReview(
                transactionDetailId: transactionDetailId,
                productId: productId,
                rating: selectedRating,
                review: reviewController.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: BlocListener<ReviewProductCubit, ReviewProductState>(
        listener: (context, state) {
          if (state is ReviewProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
          } else if (state is ReviewProductError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) return const Center(child: CircularProgressIndicator());
            if (state is OrderDetailLoaded) {
              final order = state.order;
              final status = (order.status ?? '').toLowerCase();
              final isSuccess = status == 'success' || status == 'settlement' || status == 'capture';
              final isPending = status == 'pending';
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Invoice: ${order.invoice ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('Status: ${(order.status ?? '-').toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: isSuccess ? Colors.green : Colors.orange)),
                            const SizedBox(height: 6),
                            Text('Alamat: ${order.fullAddress ?? '-'}, ${order.districtName ?? ''}, ${order.cityName ?? ''}'),
                            const SizedBox(height: 6),
                            Text('Kurir: ${order.shipping?.shippingCourier ?? '-'} - ${order.shipping?.shippingService ?? '-'}'),
                            const SizedBox(height: 6),
                            Text('Total: ${CurrencyHelper.formatRupiah(double.tryParse(order.total ?? '0') ?? 0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Daftar Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...(order.transactionDetails ?? []).map((item) => Card(
                      child: ListTile(
                        title: Text(item.product?.title ?? 'Produk'),
                        subtitle: Text('${item.qty} x ${CurrencyHelper.formatRupiah(double.tryParse(item.price ?? '0') ?? 0)}'),
                        trailing: isSuccess && item.id != null && item.productId != null
                            ? TextButton(
                                onPressed: () => _showReviewDialog(item.id!, item.productId!, item.product?.title ?? 'Produk'),
                                child: const Text('Beri Ulasan', style: TextStyle(color: Colors.orange)),
                              )
                            : null,
                      ),
                    )),
                    if (isPending && order.snapToken != null) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () => context.push('/midtransPayment/${order.snapToken}'),
                        child: const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              );
            }
            if (state is OrderError) return Center(child: Text(state.message));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
