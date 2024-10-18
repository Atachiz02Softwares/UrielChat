import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_max/flutter_paystack_max.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../custom_widgets/custom.dart';
import '../../../providers/providers.dart';
import '../../../utils/strings.dart';

class PayStack extends ConsumerStatefulWidget {
  const PayStack({super.key});

  @override
  ConsumerState<PayStack> createState() => _PayStackState();
}

class _PayStackState extends ConsumerState<PayStack> {
  bool initializingPayment = false;

  @override
  void initState() {
    super.initState();
    ref.read(planProvider.notifier).fetchCurrentPlan(ref);
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = ref.watch(planProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: CustomText(
          text: 'Upgrade Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CustomText(
              text: '${currentPlan.toUpperCase()} PLAN',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: BackgroundContainer(
        child: Center(
          child: initializingPayment
              ? const CustomProgressBar()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlanCard(
                      title: 'Regular Plan',
                      price: Strings.regularMoney,
                      buttonText: 'Upgrade to Regular',
                      buttonColor: Colors.blue.shade900,
                      onPressed: () => makePayment(Strings.regularMoney),
                    ),
                    const SizedBox(height: 20),
                    PlanCard(
                      title: 'Premium Plan',
                      price: Strings.premiumMoney,
                      buttonText: 'Upgrade to Premium',
                      buttonColor: Colors.green.shade900,
                      onPressed: () => makePayment(Strings.premiumMoney),
                    ),
                    const SizedBox(height: 20),
                    PlanCard(
                      title: 'Platinum Plan',
                      price: Strings.platinumMoney,
                      buttonText: 'Upgrade to Platinum',
                      buttonColor: Colors.purple.shade800,
                      // onPressed: () => makePayment(Strings.platinumMoney),
                      onPressed: () {
                        CustomSnackBar.showSnackBar(
                          context,
                          'Chill, Platinum plan is not available yet...',
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void makePayment(double amount) async {
    final secretKey = Strings.payStackSecretKey;
    final user = ref.read(userProvider);

    final request = PaystackTransactionRequest(
      reference: 'ps_${DateTime.now().microsecondsSinceEpoch}',
      secretKey: secretKey,
      email: user?.email ?? '',
      amount: amount * 100,
      // Convert to kobo as required by Paystack
      currency: PaystackCurrency.ngn,
      channel: [
        PaystackPaymentChannel.mobileMoney,
        PaystackPaymentChannel.card,
        PaystackPaymentChannel.ussd,
        PaystackPaymentChannel.bankTransfer,
        PaystackPaymentChannel.bank,
        PaystackPaymentChannel.qr,
        PaystackPaymentChannel.eft,
      ],
    );

    setState(() => initializingPayment = true);
    final initializedTransaction =
        await PaymentService.initializeTransaction(request);

    if (!mounted) return;
    setState(() => initializingPayment = false);

    if (!initializedTransaction.status) {
      CustomSnackBar.showSnackBar(
        context,
        initializedTransaction.message,
        isError: true,
      );
      return;
    }

    await PaymentService.showPaymentModal(
      context,
      transaction: initializedTransaction,
      callbackUrl: 'https://mopheshi.github.io/',
    );

    final response = await PaymentService.verifyTransaction(
      paystackSecretKey: secretKey,
      initializedTransaction.data?.reference ?? request.reference,
    );

    if (kDebugMode) Logger().i(response.toMap());

    if (response.status) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      final tier = amount == Strings.regularMoney ? 'regular' : 'premium';
      final dailyLimit =
          amount == Strings.regularMoney ? Strings.regular : Strings.premium;

      await userDoc.update({
        'tier': tier,
        'dailyLimit': dailyLimit,
        'transactions': FieldValue.arrayUnion([
          {
            ...response.toMap(),
            'timestamp': Timestamp.now(),
          }
        ]),
      });

      if (mounted) {
        CustomSnackBar.showSnackBar(
          context,
          'Payment successful! Your plan has been upgraded to ${tier.toUpperCase()}.',
        );
      }
    } else if (mounted) {
      CustomSnackBar.showSnackBar(
        context,
        'Payment verification failed. Please try again.',
        isError: true,
      );
    }
  }
}
