import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboards/mess/mess_sec/otp_store.dart';

/// Polls the in-memory `OtpStore.otp` and exposes it to the UI.
/// This does not change OTP generation logic; it only reads the existing value.
final otpStoreStreamProvider = StreamProvider.autoDispose<String?>((ref) {
  return Stream.periodic(
    const Duration(milliseconds: 500),
    (_) => OtpStore.otp,
  ).distinct();
});
