import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class AssignRolePage extends StatefulWidget {
  const AssignRolePage({super.key});

  @override
  State<AssignRolePage> createState() => _AssignRolePageState();
}

class _AssignRolePageState extends State<AssignRolePage> {
  final TextEditingController admissionController =
      TextEditingController();

  Map<String, dynamic>? selectedStudent;
  String selectedRole = 'Hostel Secretary';
  bool _searching = false;
  bool _assigning = false;

  // ── Search ────────────────────────────────────────────────────────────────
  Future<void> _searchStudent() async {
    final admNo = admissionController.text.trim();
    if (admNo.isEmpty) return;

    setState(() => _searching = true);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(admNo)
        .get();

    setState(() => _searching = false);

    if (!doc.exists) {
      _showSnack('Student not found', isError: true);
      setState(() => selectedStudent = null);
      return;
    }

    setState(() => selectedStudent = doc.data());
  }

  // ── Assign ────────────────────────────────────────────────────────────────
  Future<void> _assignRole() async {
    if (selectedStudent == null) return;

    final confirmed = await _confirmDialog(
      title        : 'Assign Role',
      message      : 'Assign "$selectedRole" to ${selectedStudent!['name']}?',
      confirmLabel : 'Assign',
      confirmColor : _kBlue,
    );
    if (confirmed != true) return;

    setState(() => _assigning = true);

    final admissionNo = selectedStudent!['admissionNo'];

    // ── Added: Mess Secretary support ─────────────────────────
    final updateData = selectedRole == 'Wing Secretary'
        ? {'isWingSecretary'  : true}
        : selectedRole == 'Mess Secretary'
            ? {'isMessSecretary': true}
            : {'isHostelSecretary': true};

    await FirebaseFirestore.instance
        .collection('users')
        .doc(admissionNo)
        .update(updateData);

    setState(() {
      _assigning      = false;
      selectedStudent = null;
      admissionController.clear();
    });

    _showSnack('$selectedRole assigned successfully');
  }

  // ── Remove ────────────────────────────────────────────────────────────────
  Future<void> _removeRole(
      String admissionNo, String name, String role) async {
    final confirmed = await _confirmDialog(
      title        : 'Remove Role',
      message      : 'Remove "$role" from $name?',
      confirmLabel : 'Remove',
      confirmColor : Colors.red.shade600,
    );
    if (confirmed != true) return;

    // ── Added: Mess Secretary support ─────────────────────────
    final updateData = role == 'Wing Secretary'
        ? {'isWingSecretary'  : false}
        : role == 'Mess Secretary'
            ? {'isMessSecretary': false}
            : {'isHostelSecretary': false};

    await FirebaseFirestore.instance
        .collection('users')
        .doc(admissionNo)
        .update(updateData);

    _showSnack('$role removed successfully');
  }

  // ── Confirm dialog ────────────────────────────────────────────────────────
  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color  confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 17,
                color     : _kText)),
        content: Text(message,
            style: const TextStyle(
                color: _kSubtext, fontSize: 14)),
        actionsPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              side : const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(color: _kSubtext)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: Text(confirmLabel),
          ),
        ],
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
              size : 18,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor:
            isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
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
                    20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
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
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [
                        Text('Assign Roles',
                            style: TextStyle(
                                color        : Colors.white,
                                fontSize     : 20,
                                fontWeight   : FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('Manage student role assignments',
                            style: TextStyle(
                                color  : Colors.white70,
                                fontSize: 12)),
                      ],
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
              padding: const EdgeInsets.fromLTRB(
                  20, 24, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── ASSIGN SECTION ──────────────────────────────────
                  _sectionHeader(
                      Icons.assignment_ind_rounded,
                      'Assign New Role'),
                  const SizedBox(height: 16),

                  _card(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Admission Number'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _textField(
                                controller  : admissionController,
                                hint        : 'Enter admission number',
                                icon        : Icons.badge_rounded,
                                keyboardType:
                                    TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _searching
                                ? Container(
                                    width : 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _kBlueTint,
                                      borderRadius:
                                          BorderRadius.circular(
                                              12),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width : 20,
                                        height: 20,
                                        child :
                                            CircularProgressIndicator(
                                                color      : _kBlue,
                                                strokeWidth: 2),
                                      ),
                                    ),
                                  )
                                : _blueBtn(
                                    icon   : Icons.search_rounded,
                                    label  : 'Search',
                                    onTap  : _searchStudent,
                                    compact: true,
                                  ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel('Select Role'),
                        const SizedBox(height: 6),
                        _dropdown(),

                        if (selectedStudent != null) ...[
                          const SizedBox(height: 16),
                          _studentPreviewCard(),
                          const SizedBox(height: 16),
                          _assigning
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(
                                          color: _kBlue))
                              : _blueBtn(
                                  icon : Icons
                                      .check_circle_rounded,
                                  label: 'Assign Role',
                                  onTap: _assignRole,
                                ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── CURRENT ROLES SECTION ───────────────────────────
                  _sectionHeader(
                      Icons.people_alt_rounded,
                      'Current Role Holders'),
                  const SizedBox(height: 16),

                  _RoleSection(
                    title   : 'Hostel Secretary',
                    field   : 'isHostelSecretary',
                    icon    : Icons.admin_panel_settings_rounded,
                    onRemove: _removeRole,
                  ),
                  const SizedBox(height: 12),
                  _RoleSection(
                    title   : 'Wing Secretary',
                    field   : 'isWingSecretary',
                    icon    : Icons.groups_2_rounded,
                    onRemove: _removeRole,
                  ),
                  const SizedBox(height: 12),

                  // ── Added: Mess Secretary role section ──────────────
                  _RoleSection(
                    title   : 'Mess Secretary',
                    field   : 'isMessSecretary',
                    icon    : Icons.restaurant_menu_rounded,
                    onRemove: _removeRole,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color     : Color(0x0C1565C0),
                blurRadius: 12,
                offset    : Offset(0, 4)),
          ],
        ),
        child: child,
      );

  Widget _sectionHeader(IconData icon, String title) => Row(
        children: [
          Container(
            width : 36,
            height: 36,
            decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _kBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize     : 16,
                  fontWeight   : FontWeight.w800,
                  color        : _kText,
                  letterSpacing: -0.2)),
        ],
      );

  Widget _fieldLabel(String label) => Text(label,
      style: const TextStyle(
          fontSize  : 13,
          fontWeight: FontWeight.w600,
          color     : _kText));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller  : controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: _kText),
        decoration: InputDecoration(
          hintText     : hint,
          hintStyle    : const TextStyle(
              color: _kSubtext, fontSize: 13),
          prefixIcon   : Icon(icon, color: _kBlue, size: 18),
          filled       : true,
          fillColor    : _kBg,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide  : const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide  : const BorderSide(color: _kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide  : const BorderSide(
                color: _kBlue, width: 1.5),
          ),
        ),
      );

  Widget _dropdown() => DropdownButtonFormField<String>(
        value        : selectedRole,
        style        : const TextStyle(fontSize: 14, color: _kText),
        dropdownColor: Colors.white,
        icon         : const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _kBlue),
        decoration: InputDecoration(
          prefixIcon: const Icon(
              Icons.manage_accounts_rounded,
              color: _kBlue,
              size : 18),
          filled    : true,
          fillColor : _kBg,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide  : const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide  : const BorderSide(color: _kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide  : const BorderSide(
                color: _kBlue, width: 1.5),
          ),
        ),
        // ── Added: Mess Secretary dropdown item ────────────────
        items: const [
          DropdownMenuItem(
              value: 'Hostel Secretary',
              child: Text('Hostel Secretary')),
          DropdownMenuItem(
              value: 'Wing Secretary',
              child: Text('Wing Secretary')),
          DropdownMenuItem(
              value: 'Mess Secretary',
              child: Text('Mess Secretary')),
        ],
        onChanged: (v) => setState(() => selectedRole = v!),
      );

  Widget _studentPreviewCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color       : _kBlueTint,
          borderRadius: BorderRadius.circular(14),
          border      : Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width : 44,
              height: 44,
              decoration: BoxDecoration(
                color       : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded,
                  color: _kBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedStudent!['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize  : 14,
                        color     : _kText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adm: ${selectedStudent!['admissionNo']}  •  '
                    'Dept: ${selectedStudent!['department']}',
                    style: const TextStyle(
                        fontSize: 12, color: _kSubtext),
                  ),
                  Text(
                    'Semester: ${selectedStudent!['semester']}',
                    style: const TextStyle(
                        fontSize: 12, color: _kSubtext),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  setState(() => selectedStudent = null),
              child: const Icon(Icons.close_rounded,
                  color: _kSubtext, size: 18),
            ),
          ],
        ),
      );

  Widget _blueBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool compact = false,
  }) =>
      SizedBox(
        width: compact ? null : double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon : Icon(icon, size: 18),
          label: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBlue,
            foregroundColor: Colors.white,
            elevation      : 0,
            padding        : compact
                ? const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14)
                : const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE SECTION WIDGET — unchanged, works for all 3 roles automatically
// ─────────────────────────────────────────────────────────────────────────────
class _RoleSection extends StatefulWidget {
  final String   title;
  final String   field;
  final IconData icon;
  final Future<void> Function(String admNo, String name, String role)
      onRemove;

  const _RoleSection({
    required this.title,
    required this.field,
    required this.icon,
    required this.onRemove,
  });

  @override
  State<_RoleSection> createState() => _RoleSectionState();
}

class _RoleSectionState extends State<_RoleSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(widget.field, isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs  = snapshot.data?.docs ?? [];
        final count = docs.length;

        return Container(
          decoration: BoxDecoration(
            color       : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border      : Border.all(color: _kBorder, width: 1.2),
            boxShadow   : const [
              BoxShadow(
                  color     : Color(0x0C1565C0),
                  blurRadius: 10,
                  offset    : Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width : 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color       : _kBlueTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon,
                            color: _kBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(widget.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize  : 14,
                                    color     : _kText)),
                            Text(
                              count == 0
                                  ? 'No one assigned'
                                  : '$count assigned',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color   : _kSubtext),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: count > 0
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize  : 12,
                            fontWeight: FontWeight.w700,
                            color     : count > 0
                                ? Colors.green.shade600
                                : _kSubtext,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _kSubtext,
                        size : 22,
                      ),
                    ],
                  ),
                ),
              ),

              if (_expanded) ...[
                const Divider(height: 1, color: _kBorder),
                if (count == 0)
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.grey.shade400,
                            size : 16),
                        const SizedBox(width: 8),
                        const Text(
                            'No one assigned to this role',
                            style: TextStyle(
                                color  : _kSubtext,
                                fontSize: 13)),
                      ],
                    ),
                  )
                else
                  ...docs.map((doc) {
                    final d =
                        doc.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              14, 10, 14, 10),
                          child: Row(
                            children: [
                              Container(
                                width : 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _kBlueTint,
                                  borderRadius:
                                      BorderRadius.circular(
                                          10),
                                ),
                                child: const Icon(
                                    Icons.person_rounded,
                                    color: _kBlue,
                                    size : 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(d['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                            fontSize: 13,
                                            color   : _kText)),
                                    Text(
                                        'Adm: ${d['admissionNo']}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color   : _kSubtext)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => widget.onRemove(
                                  d['admissionNo'],
                                  d['name'],
                                  widget.title,
                                ),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical  : 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors
                                            .red.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                          Icons
                                              .remove_circle_outline,
                                          color: Colors
                                              .red.shade500,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text('Remove',
                                          style: TextStyle(
                                              color: Colors
                                                  .red.shade600,
                                              fontSize : 12,
                                              fontWeight:
                                                  FontWeight
                                                      .w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (doc != docs.last)
                          const Divider(
                              height: 1,
                              indent: 62,
                              color : _kBorder),
                      ],
                    );
                  }),
              ],
            ],
          ),
        );
      },
    );
  }
}