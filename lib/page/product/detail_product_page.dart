import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/bloc/product/product_cubit.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/currency_helper.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';

class DetailProductPage extends StatefulWidget {
  final String slug;
  const DetailProductPage({super.key, required this.slug});
  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().detailProduct(widget.slug);
  }

  String _img(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : '${AppConfig.STORAGE_IMAGE}$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) return const Center(child: CircularProgressIndicator());
          if (state is ProductDetailLoaded) {
            final p = state.product;
            final rating = double.tryParse(p.ratingsAvgRating ?? '0') ?? 0.0;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Image.network(_img(p.image), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.orange.shade50, child: const Icon(Icons.fastfood, size: 64, color: Colors.orange))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(CurrencyHelper.formatRupiah(p.price), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  Row(children: [const Icon(Icons.star, color: Colors.amber, size: 20), const SizedBox(width: 4), Text('${rating.toStringAsFixed(1)} (${p.ratings?.length ?? 0} ulasan)')]),
                                ],
                              ),
                              const Divider(height: 28),
                              const Text('Deskripsi Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              HtmlWidget(p.description ?? '-'),
                              const Divider(height: 28),
                              const Text('Ulasan Pembeli', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (p.ratings == null || p.ratings!.isEmpty)
                                const Text('Belum ada ulasan untuk produk ini.', style: TextStyle(color: Colors.grey))
                              else
                                ...p.ratings!.map((r) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Text((r.customer?.name ?? 'U')[0].toUpperCase())),
                                  title: Text(r.customer?.name ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(r.review ?? ''),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text('${r.rating ?? 0}')]),
                                )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))]),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (context.read<AuthBloc>().state is! AuthAuthenticated) {
                          context.push('/login');
                          return;
                        }
                        if (p.id != null) {
                          context.read<CartBloc>().add(CartAddItem(productId: p.id!, qty: 1));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk ditambahkan ke keranjang'), backgroundColor: Colors.green));
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is ProductError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
