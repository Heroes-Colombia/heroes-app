import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/business_payment_method.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class BusinessSubscriptionService {
  BusinessSubscriptionService();
  final locator = GetIt.instance;
  final texts = GetIt.instance
      .get<AppConstants>()
      .servicesTexts["businessSubscriptionService"]!;

  //This method is used to create a token for a given card and save it in the firebase database
  Future<PaymentMethod> createCardToken(Map<String, dynamic> cardData) async {
    //First we create a POST request to wompi to create a card token
    final baseUrl = locator.get<AppConstants>().woompiBaseSandboxUrl;
    final tokenUrl =
        '$baseUrl${locator.get<AppConstants>().woompiCreateTokenUrl}';
    final response = await http
        .post(Uri.parse(tokenUrl), body: jsonEncode(cardData), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['WOOMPI_API_KEY_TEST']}'
    });

    if (response.statusCode != 201) {
      throw Exception(texts["createCardToken-error"]);
    }

    final rawData = jsonDecode(response.body);
    if (rawData["status"] != "CREATED") {
      throw Exception(texts["createCardToken-invalid-card"]);
    }

    //If the response is ok and the status is created we return the data of the card token
    final newPaymentMethod = PaymentMethod.fromWoompiJson(rawData);
    return newPaymentMethod;
  }

  Future<void> createPaymentSource() async {}

  Future<void> createSubscription() async {}

  Future<void> cancelSubscription() async {}

  Future<void> editSubscription() async {}

  Future<void> getSubscription() async {}

  Future<void> getSubscriptionList() async {}
}
