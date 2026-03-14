import 'package:flutter/material.dart';
import '../mess_sec/otp_store.dart';
import 'pm_screen.dart';

const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class PmOtpScreen extends StatefulWidget {
  const PmOtpScreen({super.key});

  @override
  State<PmOtpScreen> createState() => _PmOtpScreenState();
}

class _PmOtpScreenState extends State<PmOtpScreen> {
  final _otpController = TextEditingController();
  bool _verifying = false;

  void _verifyOtp() {
    final entered = _otpController.text.trim();

    if (entered.isEmpty) {
      _showSnack('Please enter the OTP', isError: true);
      return;
    }

    setState(() => _verifying = true);

    // OtpStore.verifyOtp checks:
    // entered == OtpStore.otp AND OtpStore.approved == true
    if (OtpStore.verifyOtp(entered)) {
      _showSnack('OTP verified! Access granted.');
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const PmScreen()),
          );
        }
      });
    } else {
      setState(() => _verifying = false);
      _showSnack('Incorrect OTP. Please try again.',
          isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: Colors.white,
          size : 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontWeight: FontWeight.w500))),
      ]),
      backgroundColor:
          isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [

          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: [_kBlue, _kBlueLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color     : Color(0x351565C0),
                  blurRadius: 18,
                  offset    : Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 14, 20, 32),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () =>
                          Navigator.maybePop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.18),
                          borderRadius:
                              BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.3)),
                        ),
                        child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size : 20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Icon
                    Container(
                      width : 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white
                                .withOpacity(0.35),
                            width: 1.5),
                      ),
                      child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size : 28),
                    ),
                    const SizedBox(height: 14),
                    const Text('Purchase Manager',
                        style: TextStyle(
                            color        : Colors.white,
                            fontSize     : 22,
                            fontWeight   : FontWeight.w800,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    const Text(
                        'Enter the OTP provided by Mess Secretary',
                        style: TextStyle(
                            color  : Colors.white70,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  24, 32, 24, 36),
              child: Column(
                children: [

                  // Info card
                  Container(
                    width  : double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _kBlueTint,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                          color: _kBorder, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width : 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _kBlue
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(
                                    11),
                          ),
                          child: const Icon(
                              Icons.info_outline_rounded,
                              color: _kBlue,
                              size : 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'The OTP is generated by the Mess Secretary. '
                            'Ask them for the code before proceeding.',
                            style: TextStyle(
                                fontSize  : 12,
                                color     : _kText,
                                fontWeight:
                                    FontWeight.w500,
                                height    : 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // OTP field
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('Enter OTP',
                          style: TextStyle(
                              fontSize  : 13,
                              fontWeight: FontWeight.w600,
                              color     : _kText)),
                      const SizedBox(height: 8),
                      TextField(
                        controller   : _otpController,
                        keyboardType : TextInputType.number,
                        textAlign    : TextAlign.center,
                        maxLength    : 6,
                        style: const TextStyle(
                          fontSize     : 28,
                          fontWeight   : FontWeight.w800,
                          color        : _kBlue,
                          letterSpacing: 10,
                        ),
                        decoration: InputDecoration(
                          counterText  : '',
                          hintText     : '------',
                          hintStyle    : TextStyle(
                              fontSize     : 28,
                              color        : _kBlue
                                  .withOpacity(0.3),
                              letterSpacing: 10),
                          filled    : true,
                          fillColor : Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: _kBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: _kBorder,
                                width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: _kBlue, width: 1.8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Verify button
                  SizedBox(
                    width : double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed:
                          _verifying ? null : _verifyOtp,
                      icon : _verifying
                          ? const SizedBox(
                              width : 18,
                              height: 18,
                              child : CircularProgressIndicator(
                                  color      : Colors.white,
                                  strokeWidth: 2))
                          : const Icon(
                              Icons.verified_rounded,
                              size: 20),
                      label: Text(
                          _verifying
                              ? 'Verifying...'
                              : 'Verify OTP',
                          style: const TextStyle(
                              fontSize  : 16,
                              fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}