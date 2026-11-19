import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/cart/cart_bloc.dart';
import 'package:flutter_foodstore/bloc/checkout/checkout_cubit.dart';
import 'package:flutter_foodstore/bloc/location/location_cubit.dart';
import 'package:flutter_foodstore/bloc/shipping_cost/shipping_cost_cubit.dart';
import 'package:flutter_foodstore/core/utils/currency_helper.dart';
import 'package:flutter_foodstore/resource/model/checkout_model.dart';
import 'package:flutter_foodstore/resource/model/location_model.dart';
import 'package:flutter_foodstore/resource/model/shipping_cost_model.dart';
import 'package:go_router/go_router.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  LocationModel? _selectedLocation;
  String _selectedCourier = 'jne';
  ShippingCostModel? _selectedService;

  @override
  void dispose() {
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartBloc>().state;
    int subtotal = 0;
    int totalWeight = 1000;
    if (cartState is CartLoaded) {
      subtotal = cartState.cartResponse.totalPrice ?? 0;
      totalWeight = (cartState.cartResponse.totalWeight ?? 0) > 0 ? cartState.cartResponse.totalWeight! : 1000;
    }
    final shippingCost = _selectedService?.cost ?? 0;
    final grandTotal = subtotal + shippingCost;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: BlocListener<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            context.read<CartBloc>().add(const CartFetch());
            context.pushReplacement('/midtransPayment/${state.snapToken}');
          } else if (state is CheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Alamat Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Search Location (Kecamatan / Kota)',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) => context.read<LocationCubit>().getLocation(val),
              ),
              BlocBuilder<LocationCubit, LocationState>(
                builder: (context, state) {
                  if (state is LocationLoading) return const LinearProgressIndicator();
                  if (state is LocationLoaded && state.locations.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.locations.length > 5 ? 5 : state.locations.length,
                        itemBuilder: (context, i) {
                          final loc = state.locations[i];
                          return ListTile(
                            dense: true,
                            title: Text(loc.label ?? '${loc.subdistrictName}, ${loc.cityName}'),
                            onTap: () {
                              setState(() {
                                _selectedLocation = loc;
                                _locationController.text = loc.label ?? '${loc.districtName}, ${loc.cityName}';
                                _selectedService = null;
                              });
                              context.read<LocationCubit>().clearLocation();
                              if (loc.id != null) {
                                context.read<ShippingCostCubit>().getShippingCost(loc.id!, totalWeight, _selectedCourier);
                              }
                            },
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Alamat Lengkap (Jalan, RT/RW, Nomor Rumah)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              const Text('Pilih Kurir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCourier,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: const [
                  DropdownMenuItem(value: 'jne', child: Text('JNE')),
                  DropdownMenuItem(value: 'pos', child: Text('POS Indonesia')),
                  DropdownMenuItem(value: 'tiki', child: Text('TIKI')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() { _selectedCourier = val; _selectedService = null; });
                    if (_selectedLocation?.id != null) {
                      context.read<ShippingCostCubit>().getShippingCost(_selectedLocation!.id!, totalWeight, val);
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<ShippingCostCubit, ShippingCostState>(
                builder: (context, state) {
                  if (state is ShippingCostLoading) return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
                  if (state is ShippingCostLoaded) {
                    return Column(
                      children: state.shippingCost.map((srv) => RadioListTile<ShippingCostModel>(
                        value: srv,
                        groupValue: _selectedService,
                        title: Text('${srv.service} (${srv.description ?? ''})'),
                        subtitle: Text('Estimasi: ${srv.etd ?? '-'} hari'),
                        secondary: Text(CurrencyHelper.formatRupiah(srv.cost), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        onChanged: (val) => setState(() => _selectedService = val),
                      )).toList(),
                    );
                  }
                  if (state is ShippingCostError) return Text(state.message, style: const TextStyle(color: Colors.red));
                  return const SizedBox.shrink();
                },
              ),
              const Divider(height: 28),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal Produk'), Text(CurrencyHelper.formatRupiah(subtotal))]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Ongkos Kirim'), Text(CurrencyHelper.formatRupiah(shippingCost))]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(CurrencyHelper.formatRupiah(grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.orange))]),
              const SizedBox(height: 20),
              BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) {
                  final loading = state is CheckoutLoading;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: loading ? null : () {
                      if (_selectedLocation == null || _addressController.text.trim().isEmpty || _selectedService == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi lokasi, alamat, dan layanan pengiriman')));
                        return;
                      }
                      context.read<CheckoutCubit>().checkout(CheckoutModel(
                        provinceName: _selectedLocation!.provinceName ?? '',
                        cityName: _selectedLocation!.cityName ?? '',
                        districtName: _selectedLocation!.districtName ?? '',
                        subdistrictName: _selectedLocation!.subdistrictName ?? '',
                        zipCode: _selectedLocation!.zipCode ?? '',
                        fullAddress: _addressController.text.trim(),
                        weight: totalWeight,
                        shippingCourier: _selectedCourier.toUpperCase(),
                        shippingService: _selectedService!.service ?? '',
                        shippingCost: shippingCost,
                        total: grandTotal,
                      ));
                    },
                    child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm and Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
