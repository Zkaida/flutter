import 'package:flutter/material.dart';
import 'package:flutter_foodstore/core/utils/currency_helper.dart';
import 'package:flutter_foodstore/resource/model/order_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'success':
      case 'settlement':
      case 'capture':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
      case 'cancel':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = order.status ?? 'pending';
    final displayStatus = statusText.isNotEmpty
        ? '${statusText[0].toUpperCase()}${statusText.substring(1)}'
        : 'Pending';
    final totalNum = double.tryParse(order.total ?? '0') ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (order.snapToken != null && order.snapToken!.isNotEmpty) {
            context.push('/orderDetail/${order.snapToken}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.invoice ?? 'INV-#', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayStatus,
                      style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${order.createdAt == null ? '-' : DateFormat('dd MMM yyyy').format(order.createdAt!)}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${CurrencyHelper.formatRupiah(totalNum)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
