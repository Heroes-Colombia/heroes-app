import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BusinessTransaction extends Equatable {
  final int amount;
  final String businessId;
  final DateTime createdAt;
  final DateTime expirationDate;
  final String id;
  final String plan;
  final String reference;

  const BusinessTransaction(
      {required this.amount,
      required this.businessId,
      required this.createdAt,
      required this.expirationDate,
      required this.id,
      required this.plan,
      required this.reference});

  @override
  List<Object?> get props =>
      [amount, businessId, createdAt, expirationDate, id, plan, reference];

  factory BusinessTransaction.fromJson(Map<String, dynamic> json) {
    return BusinessTransaction(
      amount: json['amount'],
      businessId: json['business_id'],
      createdAt: (json['created_at'] as Timestamp).toDate(),
      expirationDate: (json['expiration_date'] as Timestamp).toDate(),
      id: json['id'],
      plan: json['plan'],
      reference: json['reference'],
    );
  }
}
