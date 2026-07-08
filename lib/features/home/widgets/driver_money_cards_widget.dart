import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/widgets/payment_method_bottomsheet_widget.dart';
import 'package:ride_sharing_user_app/features/wallet/widgets/withdraw_bottom_sheet_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Dashboard cards giving drivers direct access to depositing collected cash
/// and withdrawing earnings without digging through the profile/wallet tabs.
class DriverMoneyCardsWidget extends StatelessWidget {
  const DriverMoneyCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      final wallet = profileController.profileInfo?.wallet;
      if (wallet == null) {
        return const SizedBox.shrink();
      }

      final double payable = wallet.payableBalance ?? 0;
      final double receivable = wallet.receivableBalance ?? 0;
      final double owedToCompany = payable > receivable ? payable - receivable : 0;
      final double withdrawable = receivable > payable ? receivable - payable : 0;
      final double pendingWithdrawn = wallet.pendingBalance ?? 0;

      if (owedToCompany <= 0 && withdrawable <= 0 && pendingWithdrawn <= 0) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
        child: Row(children: [
          Expanded(
            child: _MoneyCard(
              title: 'cash_to_deposit'.tr,
              amount: owedToCompany,
              icon: Icons.upload,
              color: owedToCompany > 0
                  ? Colors.orange.shade800
                  : Theme.of(context).hintColor,
              buttonText: 'deposit_now'.tr,
              enabled: owedToCompany > 0,
              onPressed: () {
                final double minToPay =
                    Get.find<SplashController>().config?.cashInHandMinAmountToPay ?? 0;
                if (owedToCompany >= minToPay) {
                  Get.bottomSheet(
                      PaymentMethodBottomsheetWidget(payableBalance: owedToCompany),
                      isScrollControlled: true);
                } else {
                  showCustomSnackBar(
                      '${'minimum_payment_amount'.tr} ${PriceConverter.convertPrice(context, minToPay)}');
                }
              },
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: _MoneyCard(
              title: 'available_for_withdrawal'.tr,
              amount: withdrawable,
              icon: Icons.download,
              color: withdrawable > 0
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor,
              buttonText: 'withdraw'.tr,
              enabled: withdrawable > 0,
              subtitle: pendingWithdrawn > 0
                  ? '${'pending_withdrawn'.tr}: ${PriceConverter.convertPrice(context, pendingWithdrawn)}'
                  : null,
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  context: context,
                  builder: (_) => const WithdrawRequestWidget(),
                );
              },
            ),
          ),
        ]),
      );
    });
  }
}

class _MoneyCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String buttonText;
  final bool enabled;
  final String? subtitle;
  final VoidCallback onPressed;

  const _MoneyCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.buttonText,
    required this.enabled,
    required this.onPressed,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor)),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(PriceConverter.convertPrice(context, amount),
            style: textRobotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor)),
        ],
        const SizedBox(height: Dimensions.paddingSizeSmall),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: enabled ? onPressed : null,
            style: TextButton.styleFrom(
              backgroundColor: enabled
                  ? color
                  : Theme.of(context).disabledColor.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.paddingSizeSmall)),
            ),
            child: Text(buttonText,
                style: textSemiBold.copyWith(
                    color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
          ),
        ),
      ]),
    );
  }
}
