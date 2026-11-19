import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/product/product_cubit.dart';
import 'package:flutter_foodstore/core/components/product_card.dart';

class AllProductPage extends StatefulWidget {
  const AllProductPage({super.key});
  @override
  State<AllProductPage> createState() => _AllProductPageState();
}

class _AllProductPageState extends State<AllProductPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semua Produk'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) return const Center(child: CircularProgressIndicator());
          if (state is ProductLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: state.products.length,
                    itemBuilder: (context, i) => ProductCard(product: state.products[i]),
                  ),
                  if (state.currentPage < state.lastPage) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      onPressed: state.isLoadingMore ? null : () => context.read<ProductCubit>().fetchProducts(page: state.currentPage + 1, loadMore: true),
                      child: state.isLoadingMore ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Load More'),
                    ),
                  ],
                ],
              ),
            );
          }
          if (state is ProductError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
