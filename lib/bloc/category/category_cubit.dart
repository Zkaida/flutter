import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/resource/model/category_model.dart';
import 'package:flutter_foodstore/resource/remote/home_remote_resource.dart';
sealed class CategoryState { const CategoryState(); }
class CategoryInitial extends CategoryState { const CategoryInitial(); }
class CategoryLoading extends CategoryState { const CategoryLoading(); }
class CategoryLoaded extends CategoryState { final List<CategoryModel> categories; const CategoryLoaded(this.categories); }
class CategoryDetailLoaded extends CategoryState { final CategoryModel category; const CategoryDetailLoaded(this.category); }
class CategoryError extends CategoryState { final String message; const CategoryError(this.message); }
class CategoryCubit extends Cubit<CategoryState> {
  final HomeRemoteResource homeRemoteResource;
  CategoryCubit(this.homeRemoteResource) : super(const CategoryInitial());
  Future<void> fetchCategories() async {
    emit(const CategoryLoading());
    final res = await homeRemoteResource.fetchCategories();
    res.fold((e) => emit(CategoryError(e)), (c) => emit(CategoryLoaded(c)));
  }
  Future<void> fetchCategoryBySlug(String slug) async {
    emit(const CategoryLoading());
    final res = await homeRemoteResource.fetchCategoryBySlug(slug);
    res.fold((e) => emit(CategoryError(e)), (c) => emit(CategoryDetailLoaded(c)));
  }
}
