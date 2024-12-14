import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class Phonepepayment extends StatefulWidget {
  const Phonepepayment({super.key});

  @override
  State<Phonepepayment> createState() => _PhonepepaymentState();
}

class _PhonepepaymentState extends State<Phonepepayment> {
  String environmentValue = "SANDBOX";
  String appId = "";
  String merchantId = "PGTESTPAYUAT86";
  bool enableLogging = true;
  String checksum = "";
  String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  String saltIndex = "1";
  String body = "";
  String callback = "https://webhook.site/3a88cbf9-f63e-4e55-b1e5-4fa9fba3d20b";
  String packageName = "";
  String apiEndPoint = "/pg/v1/pay";

  Object? result;
  bool isPaymentInProgress = false; // Prevent multiple button presses during payment

  @override
  void initState() {
    super.initState();
    body = getChecksum().toString();
    initPayment();
  }

  // Initialize the PhonePe SDK
  void initPayment() {
    PhonePePaymentSdk.init(environmentValue, appId, merchantId, enableLogging)
        .then((val) {
      setState(() {
        result = 'PhonePe SDK Initialized - $val';
      });
    }).catchError((error) {
      handleError(error);
    });
  }

  // Handle the transaction
  Future<void> startTransaction() async {
    if (isPaymentInProgress) {
      // Prevent further clicks until payment is completed
      return;
    }

    setState(() {
      isPaymentInProgress = true; // Mark payment as in progress
    });

    try {
      var response = await PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName);
      setState(() {
        if (response != null) {
          String status = response['status'].toString();
          String error = response['error'].toString();
          if (status == 'SUCCESS') {
            result = "Flow Completed - Status: Success!";
          } else {
            result = "Flow Completed - Status: $status and Error: $error";
          }
        } else {
          result = "Flow Incomplete";
        }
        isPaymentInProgress = false; // Reset payment progress
      });
    } catch (error) {
      setState(() {
        result = "Error occurred: $error";
        isPaymentInProgress = false; // Reset on error
      });
      if (error.toString().contains("TOO_MANY_REQUESTS")) {
        await retryTransaction();
      }
    }
  }

  // Retry logic with exponential backoff in case of TOO_MANY_REQUESTS
  Future<void> retryTransaction() async {
    int retries = 3;
    int delay = 2; // Initial retry delay in seconds

    while (retries > 0) {
      try {
        await Future.delayed(Duration(seconds: delay)); // Exponential backoff
        await startTransaction();
        break; // Exit if successful
      } catch (e) {
        if (e.toString().contains("TOO_MANY_REQUESTS") && retries > 0) {
          retries--;
          delay *= 2; // Double the delay for next retry
        } else {
          break; // Exit on other errors
        }
      }
    }
  }

  // Generate checksum
  String getChecksum() {
    final reqdata = {
      "merchantId": merchantId,
      "merchantTransactionId": "t_52554",
      "merchantUserId": "MUID123",
      "amount": 1000,
      "callbackUrl": callback, // Provide a valid callback URL
      "mobileNumber": "9999999999",
      "paymentInstrument": {
        "type": "PAY_PAGE"
      }
    };

    String base64body = base64.encode(utf8.encode(json.encode(reqdata)));

    checksum = '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64body;
  }

  // Error handling function
  void handleError(error) {
    setState(() {
      result = "Error: $error.Please try again later.";
      isPaymentInProgress = false; // Reset flag after error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PAYMENT"),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: isPaymentInProgress ? null : startTransaction, // Disable button during transaction
              child: Text(isPaymentInProgress ? 'Processing...' : 'Pay Now'),
            ),
          ),
          SizedBox(height: 20),
          Text(
            result != null ? '$result' : '',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
