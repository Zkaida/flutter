import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/category/category_cubit.dart';
import 'package:flutter_foodstore/core/components/product_card.dart';

class ProductByCategoryPage extends StatefulWidget {
  final String slug;
  const ProductByCategoryPage({super.key, required this.slug});
  @override
  State<ProductByCategoryPage> createState() => _ProductByCategoryPageState();
}

class _ProductByCategoryPageState extends State<ProductByCategoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().fetchCategoryBySlug(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk Kategori'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) return const Center(child: CircularProgressIndicator());
          if (state is CategoryDetailLoaded) {
            final products = state.category.products ?? [];
            if (products.isEmpty) return const Center(child: Text('Belum ada produk di kategori ini'));
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: products.length,
              itemBuilder: (context, i) => ProductCard(product: products[i]),
            );
          }
          if (state is CategoryError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
