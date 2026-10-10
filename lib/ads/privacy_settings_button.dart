import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';

/// Lets users in regions that require it (EU/UK) change their ad choices.
/// Hidden everywhere else.
class PrivacySettingsButton extends StatelessWidget {
  const PrivacySettingsButton({super.key});

  Future<bool> _isRequired() async {
    if (!AdService.enabled) return false;
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isRequired(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return Center(
          child: TextButton(
            onPressed: () => ConsentForm.showPrivacyOptionsForm((FormError? e) {
              if (e != null) debugPrint('Privacy form error: ${e.message}');
            }),
            child: const Text('Ad privacy settings'),
          ),
        );
      },
    );
  }
}
