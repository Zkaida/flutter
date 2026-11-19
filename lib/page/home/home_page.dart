import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/bloc/category/category_cubit.dart';
import 'package:flutter_foodstore/bloc/product/product_cubit.dart';
import 'package:flutter_foodstore/bloc/product_populer/product_populer_cubit.dart';
import 'package:flutter_foodstore/bloc/slider/slider_cubit.dart';
import 'package:flutter_foodstore/core/components/product_card.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<SliderCubit>().fetchSliders();
    context.read<CategoryCubit>().fetchCategories();
    context.read<ProductPopulerCubit>().fetchProductsPopuler();
    context.read<ProductCubit>().fetchProducts(page: 1);
  }

  String _img(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : '${AppConfig.STORAGE_IMAGE}$path';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartStored) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green, duration: const Duration(seconds: 1)));
        }
      },
      child: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sliders
              BlocBuilder<SliderCubit, SliderState>(
                builder: (context, state) {
                  if (state is SliderLoaded && state.sliders.isNotEmpty) {
                    return SizedBox(
                      height: 165,
                      child: PageView.builder(
                        itemCount: state.sliders.length,
                        itemBuilder: (context, i) {
                          final url = _img(state.sliders[i].image);
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.orange.shade100, child: const Center(child: Icon(Icons.image, color: Colors.orange)))),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox(height: 12);
                },
              ),
              // Categories
              const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: Text('Categories', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                  if (state is CategoryLoaded) {
                    return SizedBox(
                      height: 98,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final cat = state.categories[i];
                          return GestureDetector(
                            onTap: () { if (cat.slug != null) context.push('/productByCategory/${cat.slug}'); },
                            child: SizedBox(
                              width: 74,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.orange.shade50,
                                    backgroundImage: cat.image != null ? NetworkImage(_img(cat.image)) : null,
                                    child: cat.image == null ? const Icon(Icons.category, color: Colors.orange) : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(cat.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Product Popular
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Product Popular', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => context.push('/allProduct'), child: const Text('Lihat Semua', style: TextStyle(color: Colors.orange))),
                  ],
                ),
              ),
              BlocBuilder<ProductPopulerCubit, ProductPopulerState>(
                builder: (context, state) {
                  if (state is ProductPopulerLoaded) {
                    return SizedBox(
                      height: 235,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.products.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => SizedBox(width: 165, child: ProductCard(product: state.products[i])),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Product Terbaru
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Product Terbaru', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => context.push('/allProduct'), child: const Text('Lihat Semua', style: TextStyle(color: Colors.orange))),
                  ],
                ),
              ),
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                  if (state is ProductLoaded) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: state.products.length,
                      itemBuilder: (context, i) => ProductCard(product: state.products[i]),
                    );
                  }
                  if (state is ProductError) return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(state.message)));
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
