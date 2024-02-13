import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String status;
  final String id;
  final DateTime createdAt;
  final String brand;
  final String name;
  final String lastFourNumbers;
  final String bin;
  final String cardHolder;
  final DateTime expiresAt;
  final int? paymentMethodId;

  const PaymentMethod({
    required this.status,
    required this.id,
    required this.createdAt,
    required this.brand,
    required this.name,
    required this.lastFourNumbers,
    required this.bin,
    required this.cardHolder,
    required this.expiresAt,
    required this.paymentMethodId,
  });

  @override
  List<Object?> get props => [
        status,
        id,
        createdAt,
        brand,
        name,
        lastFourNumbers,
        bin,
        cardHolder,
        expiresAt,
        paymentMethodId,
      ];

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] as Timestamp;
    final expiresAt = json['expires_at'] as Timestamp;

    return PaymentMethod(
      status: json['status'] as String,
      id: json['id'] as String,
      createdAt: createdAt.toDate(),
      brand: json['brand'] as String,
      name: json['name'] as String,
      lastFourNumbers: json['last_four'] as String,
      bin: json['bin'] as String,
      cardHolder: json['card_holder'] as String,
      expiresAt: expiresAt.toDate(),
      paymentMethodId: json['payment_method_id'] as int?,
    );
  }

  factory PaymentMethod.fromWoompiJson(Map<String, dynamic> woompiJson) {
    final json = woompiJson['data'] as Map<String, dynamic>;
    return PaymentMethod(
      status: woompiJson['status'] as String,
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      brand: json['brand'] as String,
      name: json['name'] as String,
      lastFourNumbers: json['last_four'] as String,
      bin: json['bin'] as String,
      cardHolder: json['card_holder'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      paymentMethodId: json['payment_method_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'id': id,
      'created_at': createdAt,
      'brand': brand,
      'name': name,
      'last_four': lastFourNumbers,
      'bin': bin,
      'card_holder': cardHolder,
      'expires_at': expiresAt,
      'payment_method_id': paymentMethodId,
    };
  }
}
