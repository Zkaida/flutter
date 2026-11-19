import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/currency_helper.dart';
import 'package:flutter_foodstore/resource/model/product_model.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  String _resolveImageUrl(String? image) {
    if (image == null || image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return '${AppConfig.STORAGE_IMAGE}$image';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(product.image);
    final rating = double.tryParse(product.ratingsAvgRating ?? '0') ?? 0.0;

    return GestureDetector(
      onTap: () {
        if (product.slug != null) {
          context.push('/detailProduct/${product.slug}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.orange.shade50,
                          child: const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                        ),
                      )
                    : Container(
                        color: Colors.orange.shade50,
                        child: const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title ?? 'Produk',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyHelper.formatRupiah(product.price),
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, size: 15, color: Colors.amber),
                                const SizedBox(width: 3),
                                Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                final isLoggedIn = context.read<AuthBloc>().state is AuthAuthenticated;
                                if (!isLoggedIn) {
                                  context.push('/login');
                                  return;
                                }
                                if (product.id != null) {
                                  context.read<CartBloc>().add(CartAddItem(productId: product.id!, qty: 1));
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
