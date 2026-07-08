import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Shows when a trip request was made and a live countdown until it expires
/// (based on the admin-configured trip request active time).
class TripRequestTimerWidget extends StatefulWidget {
  final String? createdAt;
  const TripRequestTimerWidget({super.key, required this.createdAt});

  @override
  State<TripRequestTimerWidget> createState() => _TripRequestTimerWidgetState();
}

class _TripRequestTimerWidgetState extends State<TripRequestTimerWidget> {
  Timer? _timer;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _createdAt = DateTime.tryParse(widget.createdAt ?? '')?.toLocal();
    if (_createdAt != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _requestedAgo(Duration elapsed) {
    if (elapsed.inMinutes < 1) {
      return 'just_now'.tr;
    }
    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} ${'min_ago'.tr}';
    }
    return '${elapsed.inHours}h ${elapsed.inMinutes % 60}m ${'ago'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    if (_createdAt == null) {
      return const SizedBox.shrink();
    }

    final int activeMinutes =
        Get.find<SplashController>().config?.tripRequestActiveTime ?? 10;
    final DateTime now = DateTime.now();
    final Duration elapsed = now.difference(_createdAt!);
    final Duration remaining =
        _createdAt!.add(Duration(minutes: activeMinutes)).difference(now);
    final bool expired = remaining.isNegative;

    final String countdown = expired
        ? 'expired'.tr
        : '${'expires_in'.tr} ${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: (expired ? Theme.of(context).colorScheme.error : Colors.orange)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(Icons.schedule,
                size: 12, color: Theme.of(context).hintColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              '${'requested'.tr} ${_requestedAgo(elapsed)}',
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ]),
          Row(children: [
            Icon(
              expired ? Icons.timer_off_outlined : Icons.timer_outlined,
              size: 12,
              color: expired
                  ? Theme.of(context).colorScheme.error
                  : Colors.orange.shade800,
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              countdown,
              style: textSemiBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: expired
                    ? Theme.of(context).colorScheme.error
                    : Colors.orange.shade800,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
