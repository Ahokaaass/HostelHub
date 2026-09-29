class OtpStore {
  static String? otp;
  static bool otpSubmitted = false;
  static bool approved = false;
  static String? phone;

  static void reset() {
    otp = null;
    otpSubmitted = false;
    approved = false;
    phone = null;
  }

  static bool verifyOtp(String enteredOtp) {
    if (otp != null && enteredOtp == otp && approved) {
      otpSubmitted = true;
      return true;
    }
    return false;
  }

  static bool canAccessPM() => approved && otpSubmitted;
}
