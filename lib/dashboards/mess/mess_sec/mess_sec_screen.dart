import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'otp_store.dart';
import '../../../models/mess_admin_sample_data.dart';
import '../../../services/orders_service.dart';
import '../../../widgets/dashboard_card.dart';

import 'billing_overview_screen.dart';
import 'duty_allocation_screen.dart';
import 'menu_management_screen.dart';
import 'mess_complaints_screen.dart';
import 'purchase_entry_screen.dart';

const _kBlue = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint = Color(0xFFE8F0FE);
const _kBorder = Color(0xFFBBD0F8);
const _kBg = Color(0xFFF5F8FF);
const _kText = Color(0xFF1A1A2E);
const _kSubtext = Color(0xFF6B7280);

class MessSecScreen extends StatefulWidget {
  const MessSecScreen({super.key});

  @override
  State<MessSecScreen> createState() => _MessSecScreenState();
}

class _MessSecScreenState extends State<MessSecScreen> {
  final GlobalKey _inventoryAnchorKey = GlobalKey();
  final OrdersService _ordersService = OrdersService();
  final GlobalKey<FormState> _inventoryFormKey = GlobalKey<FormState>();

  // ── Ordered / Final lists ─────────────────────────────────────────────────
  final List<Map<String, String>> _ordered = [];
  final List<Map<String, String>> _finalList = [];

  final _itemC = TextEditingController();
  final _qtyC = TextEditingController();
  final _brandC = TextEditingController();
  final List<String> _unitOptions = const ['kg', 'g', 'L', 'ml', 'pcs', 'pack'];
  String? _selectedUnit;
  bool _showInventoryErrors = false;

  // ── OTP ───────────────────────────────────────────────────────────────────
  final _studentNumC = TextEditingController();
  String? _generatedOtp;

  // ── Loading ───────────────────────────────────────────────────────────────
  bool _sendingOrder = false;
  bool _sentToPm = false;

  bool get _isInventoryFormValid =>
      _itemC.text.trim().isNotEmpty &&
      _qtyC.text.trim().isNotEmpty &&
      _selectedUnit != null &&
      num.tryParse(_qtyC.text.trim()) != null &&
      (num.tryParse(_qtyC.text.trim()) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _itemC.addListener(_onInventoryInputChanged);
    _qtyC.addListener(_onInventoryInputChanged);
  }

  @override
  void dispose() {
    _itemC.removeListener(_onInventoryInputChanged);
    _qtyC.removeListener(_onInventoryInputChanged);
    _itemC.dispose();
    _qtyC.dispose();
    _brandC.dispose();
    _studentNumC.dispose();
    super.dispose();
  }

  void _onInventoryInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ── Add item ──────────────────────────────────────────────────────────────
  void _addItem() {
    final formOk = _inventoryFormKey.currentState?.validate() ?? false;
    if (!formOk || _selectedUnit == null) {
      setState(() => _showInventoryErrors = true);
      _showSnack('Please fill all required fields', isError: true);
      return;
    }
    setState(() {
      _ordered.add({
        'item': _itemC.text.trim(),
        'qty': '${_qtyC.text.trim()} ${_selectedUnit!}',
        'brand': _brandC.text.trim(),
      });
      _sentToPm = false;
      _showInventoryErrors = false;
      _itemC.clear();
      _qtyC.clear();
      _brandC.clear();
      _selectedUnit = null;
    });
  }

  // ── Move ordered → final ──────────────────────────────────────────────────
  void _moveToFinal() {
    if (_ordered.isEmpty) return;
    setState(() {
      _finalList.addAll(_ordered);
      _ordered.clear();
      _sentToPm = false;
    });
    _showSnack('All items moved to Final List');
  }

  // ── Send final list to Firestore ──────────────────────────────────────────
  Future<void> _sendToFirestore() async {
    if (_finalList.isEmpty) return;
    setState(() => _sendingOrder = true);

    try {
      final payload = _finalList
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
      await _ordersService.sendOrderToPurchaseManager(items: payload);
      setState(() => _finalList.clear());
      setState(() => _sentToPm = true);
      _showSnack('Final list sent to Purchase Manager');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }

    setState(() => _sendingOrder = false);
  }

  // ── Generate OTP ──────────────────────────────────────────────────────────
  void _generateOtp() {
    if (_studentNumC.text.trim().isEmpty) return;
    final otp = (100000 + Random().nextInt(900000)).toString();
    OtpStore.otp = otp;
    OtpStore.approved = true;
    OtpStore.phone = _studentNumC.text.trim();
    setState(() => _generatedOtp = otp);
  }

  // ── Verify delivery ───────────────────────────────────────────────────────
  Future<void> _verifyDelivery(DocumentReference ref) async {
    await ref.update({'status': 'VERIFIED'});
    _showSnack('Delivery verified and forwarded!');
  }

  // ── Switch Role bottom sheet ──────────────────────────────────────────────
  void _showSwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Switch Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select the role you want to switch to',
                style: TextStyle(fontSize: 13, color: _kSubtext),
              ),
            ),
            const SizedBox(height: 20),

            // ── Mess Secretary (active) ───────────────────────────
            _RoleTile(
              icon: Icons.restaurant_menu_rounded,
              iconColor: _kBlue,
              iconBg: _kBlueTint,
              title: 'Mess Secretary',
              subtitle: 'Manage orders, deliveries & OTP',
              isActive: true,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),

            // ── Student ───────────────────────────────────────────
            _RoleTile(
              icon: Icons.person_rounded,
              iconColor: _kSubtext,
              iconBg: const Color(0xFFF3F4F6),
              title: 'Student',
              subtitle: 'Access your student dashboard',
              isActive: false,
              onTap: () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context); // go back to student dashboard
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kBlue, _kBlueLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x351565C0),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mess Secretary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Manage orders, deliveries & OTP',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Active Role Banner ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_kBlue, _kBlueLight],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x301565C0),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mess Secretary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Currently active role',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF69FF83),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Switch Role Card ──────────────────────────────────
                  GestureDetector(
                    onTap: () => _showSwitchSheet(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _kBorder, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C1565C0),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _kBlueTint,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: _kBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Switch Role',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _kText,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Tap to switch between your roles',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _kSubtext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _kBlueTint,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: _kBlue,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Overview Cards (replaces "Others" tab) ────────────────
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                    children: [
                      DashboardCard(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'Menu Management',
                        description:
                            '${MessAdminSampleData.weeklyMenu.length}-day menu',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MenuManagementScreen(),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      DashboardCard(
                        icon: Icons.inventory_2_rounded,
                        title: 'Inventory',
                        description:
                            'Ordered: ${_ordered.length} • Final: ${_finalList.length}',
                        onTap: () {
                          final ctx = _inventoryAnchorKey.currentContext;
                          if (ctx == null) return;
                          Scrollable.ensureVisible(
                            ctx,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOut,
                          );
                        },
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      DashboardCard(
                        icon: Icons.shopping_cart_rounded,
                        title: 'Purchases',
                        description: 'Procured items sent to admin',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PurchaseEntryScreen(),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      DashboardCard(
                        icon: Icons.calendar_today_rounded,
                        title: 'Duty Allocation',
                        description:
                            '${MessAdminSampleData.dutyAllocation.length} duty slots',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DutyAllocationScreen(),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('complaints')
                            .where('category', isEqualTo: 'Mess Complaint')
                            .where('currentStage', isEqualTo: 'Mess Secretary')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.docs.length ?? 0;
                          final desc =
                              snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? 'Loading...'
                              : '$count pending';
                          return DashboardCard(
                            icon: Icons.report_problem_outlined,
                            title: 'Complaints',
                            description: desc,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MessComplaintsScreen(),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Billing Overview',
                        description:
                            'Total: ₹${MessAdminSampleData.totalBill()}',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BillingOverviewScreen(),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── ORDERED LIST ──────────────────────────────────────
                  KeyedSubtree(
                    key: _inventoryAnchorKey,
                    child: _sectionHeader(
                      Icons.shopping_cart_rounded,
                      'Pre-procured List',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Inventory Item',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _kText,
                              ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: _kBorder),
                        const SizedBox(height: 14),
                        Form(
                          key: _inventoryFormKey,
                          autovalidateMode: _showInventoryErrors
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: _itemC,
                                label: 'Commodity Name',
                                hint: 'Enter commodity name',
                                icon: Icons.inventory_2_outlined,
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Commodity name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _qtyC,
                                      label: 'Quantity',
                                      hint: 'Enter quantity',
                                      icon: Icons.scale_outlined,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      validator: (value) {
                                        final raw = (value ?? '').trim();
                                        if (raw.isEmpty) {
                                          return 'Quantity is required';
                                        }
                                        final parsed = num.tryParse(raw);
                                        if (parsed == null || parsed <= 0) {
                                          return 'Enter a valid quantity';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomDropdown(
                                      label: 'Unit',
                                      hint: 'Select unit',
                                      value: _selectedUnit,
                                      icon: Icons.straighten_rounded,
                                      items: _unitOptions,
                                      errorText:
                                          _showInventoryErrors &&
                                              _selectedUnit == null
                                          ? 'Unit is required'
                                          : null,
                                      onChanged: (value) {
                                        setState(() => _selectedUnit = value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _brandC,
                                label: 'Brand (optional)',
                                hint: 'Enter brand name',
                                icon: Icons.branding_watermark_outlined,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isInventoryFormValid
                                      ? _addItem
                                      : null,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add Item'),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_ordered.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: _kBorder),
                          const SizedBox(height: 10),
                          ..._ordered.asMap().entries.map(
                            (e) => _itemRow(e.value, e.key, _ordered),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── FINAL LIST ────────────────────────────────────────
                  _sectionHeader(
                    Icons.playlist_add_check_rounded,
                    'Final List',
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _blueBtn(
                                icon: Icons.move_down_rounded,
                                label: 'Move All to Final',
                                onTap: _moveToFinal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _sendingOrder
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: _kBlue,
                                      ),
                                    )
                                  : _blueBtn(
                                      icon: Icons.send_rounded,
                                      label: _sentToPm
                                          ? 'Sent to PM'
                                          : 'Send to PM',
                                      onTap: _sentToPm
                                          ? null
                                          : _sendToFirestore,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _sentToPm
                                ? 'Status: Sent to PM'
                                : 'Status: Pending Approval',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _sentToPm
                                  ? Colors.green.shade700
                                  : _kSubtext,
                            ),
                          ),
                        ),
                        if (_finalList.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: _kBorder),
                          const SizedBox(height: 10),
                          ..._finalList.asMap().entries.map(
                            (e) => _itemRow(e.value, e.key, _finalList),
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.grey.shade400,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'No items in final list yet',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _kSubtext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── RECEIVED LIST ─────────────────────────────────────
                  _sectionHeader(Icons.inventory_2_rounded, 'Procured List'),
                  const SizedBox(height: 12),
                  _buildReceivedList(),

                  const SizedBox(height: 24),

                  // ── STUDENT OTP ───────────────────────────────────────
                  _sectionHeader(Icons.lock_rounded, 'Student OTP Generation'),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Student Number'),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _studentNumC,
                          hint: 'Enter student number',
                          icon: Icons.badge_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        _blueBtn(
                          icon: Icons.vpn_key_rounded,
                          label: 'Generate OTP',
                          onTap: _generateOtp,
                        ),
                        if (_generatedOtp != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _kBlueTint,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _kBorder),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Generated OTP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _kSubtext,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _generatedOtp!,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: _kBlue,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  // ── Received list stream ──────────────────────────────────────────────────
  Widget _buildReceivedList() => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('daily_deliveries')
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: _kBlue),
          ),
        );
      }

      if (snapshot.data!.docs.isEmpty) {
        return _card(
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.grey.shade400,
                size: 16,
              ),
              const SizedBox(width: 10),
              const Text(
                'No items received yet',
                style: TextStyle(fontSize: 12, color: _kSubtext),
              ),
            ],
          ),
        );
      }

      final doc = snapshot.data!.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(
        data['receivedItems'] ?? [],
      );
      final status = data['status'] as String? ?? '';
      final isVerified = status == 'VERIFIED';

      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green.shade50 : _kBlueTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isVerified
                        ? Icons.verified_rounded
                        : Icons.local_shipping_rounded,
                    color: isVerified ? Colors.green.shade600 : _kBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isVerified ? 'Verified' : 'Pending Verification',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isVerified ? Colors.green.shade600 : _kText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: _kBorder),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Item',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: _kSubtext,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Qty',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: _kSubtext,
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  'Brand',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: _kSubtext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['item']?.toString() ?? '',
                        style: const TextStyle(fontSize: 12, color: _kText),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item['qty']?.toString() ?? '',
                      style: const TextStyle(fontSize: 12, color: _kText),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      item['brand']?.toString() ?? '',
                      style: const TextStyle(fontSize: 12, color: _kText),
                    ),
                  ],
                ),
              ),
            ),
            if (!isVerified) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _verifyDelivery(doc.reference),
                  icon: const Icon(Icons.verified_rounded, size: 18),
                  label: const Text(
                    'Verify & Forward',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );

  // ── Item row ──────────────────────────────────────────────────────────────
  Widget _itemRow(
    Map<String, String> item,
    int index,
    List<Map<String, String>> list,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _kBlueTint,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.fastfood_rounded, color: _kBlue, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['item'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _kText,
                ),
              ),
              Text(
                '${item['qty']}  •  ${item['brand']}',
                style: const TextStyle(fontSize: 11, color: _kSubtext),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => list.removeAt(index)),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade400,
              size: 14,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _kBorder, width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C1565C0),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _sectionHeader(IconData icon, String title) => Row(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _kBlueTint,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _kBlue, size: 18),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: _kText,
          letterSpacing: -0.2,
        ),
      ),
    ],
  );

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _kText,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14, color: _kText),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kSubtext, fontSize: 13),
      prefixIcon: Icon(icon, color: _kBlue, size: 18),
      filled: true,
      fillColor: _kBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBlue, width: 1.5),
      ),
    ),
  );

  Widget _blueBtn({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final IconData icon;
  final List<String> items;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.items,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      items: items
          .map(
            (unit) => DropdownMenuItem<String>(value: unit, child: Text(unit)),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE TILE — reusable for the switch sheet
// ─────────────────────────────────────────────────────────────────────────────
class _RoleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? _kBlueTint : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? _kBlue : _kBorder,
            width: isActive ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isActive ? _kBlue : iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isActive ? _kBlue : _kText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _kSubtext),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _kBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: _kSubtext,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// MODIFIED SINGLE MESS DASHBOARDDDDDDD
