import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/currency_helper.dart';
import 'package:go_router/go_router.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartFetch());
  }

  String _img(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : '${AppConfig.STORAGE_IMAGE}$path';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) return const Center(child: CircularProgressIndicator());
        if (state is CartLoaded) {
          final carts = state.cartResponse.carts ?? [];
          if (carts.isEmpty) {
            return const Center(child: Text('Keranjang belanja masih kosong'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: carts.length,
                  itemBuilder: (context, i) {
                    final item = carts[i];
                    final prod = item.product;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(_img(prod?.image), width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.orange.shade50, child: const Icon(Icons.fastfood, color: Colors.orange))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prod?.title ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(CurrencyHelper.formatRupiah(prod?.price), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                                        onPressed: () {
                                          if (item.id != null && item.productId != null) {
                                            if ((item.qty ?? 1) > 1) {
                                              context.read<CartBloc>().add(CartDecrementItem(productId: item.productId!, cartId: item.id!));
                                            } else {
                                              context.read<CartBloc>().add(CartRemoveItem(cartId: item.id!));
                                            }
                                          }
                                        },
                                      ),
                                      Text('${item.qty ?? 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                                        onPressed: () {
                                          if (item.id != null && item.productId != null) {
                                            context.read<CartBloc>().add(CartIncrementItem(productId: item.productId!, cartId: item.id!));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () { if (item.id != null) context.read<CartBloc>().add(CartRemoveItem(cartId: item.id!)); },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Harga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(CurrencyHelper.formatRupiah(state.cartResponse.totalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => context.push('/checkout'),
                        child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        if (state is CartError) return Center(child: Text(state.message));
        return const SizedBox.shrink();
      },
    );
  }
}
