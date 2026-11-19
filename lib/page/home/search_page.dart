import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/product/product_cubit.dart';
import 'package:flutter_foodstore/core/components/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(hintText: 'Ketik nama makanan...', hintStyle: TextStyle(color: Colors.white70), border: InputBorder.none),
          onChanged: (val) => context.read<ProductCubit>().fetchProducts(page: 1, query: val),
        ),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) return const Center(child: CircularProgressIndicator());
          if (state is ProductLoaded) {
            if (state.products.isEmpty) return const Center(child: Text('Produk tidak ditemukan'));
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: state.products.length,
              itemBuilder: (context, i) => ProductCard(product: state.products[i]),
            );
          }
          return const Center(child: Text('Cari makanan favoritmu'));
        },
      ),
    );
  }
}
