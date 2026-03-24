import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue       = Color(0xFF1565C0);
const _kBlueLight  = Color(0xFF1E88E5);
const _kBlueTint   = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);
const _kBg         = Color(0xFFF5F8FF);
const _kDark       = Color(0xFF1A1A2E);
const _kGrey       = Color(0xFF6B7280);

// ── Role config ───────────────────────────────────────────────────────────────
const _roleLabels = {
  'principal': 'Principal',       // ← ADDED
  'matron'   : 'Matron',
  'rt'       : 'Resident Tutor',
  'warden'   : 'Warden',
  'security' : 'Security Staff',
};

const _roleIcons = {
  'principal': Icons.account_balance_rounded, // ← ADDED
  'matron'   : Icons.medical_services_rounded,
  'rt'       : Icons.school_rounded,
  'warden'   : Icons.security_rounded,
  'security' : Icons.shield_rounded,
};

const _roleColors = {
  'principal': Color(0xFF6A1B9A), // deep purple ← ADDED
  'matron'   : Color(0xFF7B1FA2),
  'rt'       : Color(0xFF1565C0),
  'warden'   : Color(0xFF2E7D32),
  'security' : Color(0xFFE65100),
};

// Roles that must pick a specific hostel (not common)
const _hostelSpecificRoles = ['matron', 'rt'];

// Roles that are always common — no hostel picker needed at all
const _commonOnlyRoles = ['principal', 'warden']; // ← principal added

// Hostels for dropdown
const _hostelOptions = [
  {'value': 'nila',   'label': 'Nila'},
  {'value': 'kabani', 'label': 'Kabani'},
  {'value': 'common', 'label': 'Common (Both Hostels)'},
];

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  String _filterRole = 'all';

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _deleteStaff(
      BuildContext context, String docId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Staff',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 17)),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
                color: _kGrey, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Are you sure you want to remove '),
              TextSpan(
                text: name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: _kDark),
              ),
              const TextSpan(
                  text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('staff')
          .doc(docId)
          .delete();
      if (mounted) {
        _showSnack('$name removed.', Colors.red.shade600);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 130,
            pinned          : true,
            backgroundColor : _kBlue,
            foregroundColor : Colors.white,
            elevation       : 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin : Alignment.topLeft,
                        end   : Alignment.bottomRight,
                        colors: [Color(0xFF0D47A1), _kBlueLight],
                      ),
                    ),
                  ),
                  Positioned(
                      top: -30, right: -30,
                      child: _circle(120, 0.07)),
                  Positioned(
                      bottom: -20, left: -20,
                      child: _circle(90, 0.05)),
                ],
              ),
              title: const Text('Staff Management',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize  : 18,
                      color     : Colors.white)),
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Add Staff',
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size : 20),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddStaffPage()),
                  ),
                ),
              ),
            ],
          ),
        ],
        body: Column(
          children: [
            // ── Role filter chips ───────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label   : 'All',
                      selected: _filterRole == 'all',
                      onTap   : () =>
                          setState(() => _filterRole = 'all'),
                    ),
                    const SizedBox(width: 8),
                    ..._roleLabels.entries.map((e) => Padding(
                          padding:
                              const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label   : e.value,
                            selected: _filterRole == e.key,
                            color   : _roleColors[e.key],
                            onTap   : () => setState(
                                () => _filterRole = e.key),
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // ── Staff list ──────────────────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('staff')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: _kBlue));
                  }

                  var docs = snapshot.data!.docs;

                  if (_filterRole != 'all') {
                    docs = docs.where((d) {
                      final data =
                          d.data() as Map<String, dynamic>;
                      return data['role'] == _filterRole;
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_off_rounded,
                              size : 64,
                              color: _kBlue.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            _filterRole == 'all'
                                ? 'No staff added yet'
                                : 'No ${_roleLabels[_filterRole] ?? _filterRole} found',
                            style: const TextStyle(
                                color  : _kGrey,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d =
                          docs[index].data()
                              as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final name  = d['name'] ?? '—';

                      return _StaffCard(
                        data    : d,
                        onDelete: () => _deleteStaff(
                            context, docId, name),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddStaffPage()),
        ),
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        icon : const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff',
            style:
                TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  static Widget _circle(double size, double opacity) =>
      Container(
        width : size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

// ── Staff Card ────────────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback         onDelete;
  const _StaffCard(
      {required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name   = data['name']   ?? '—';
    final role   = data['role']   ?? 'unknown';
    final hostel = data['hostel'] ?? 'Common';
    final userId =
        data['userId'] ?? data['staffId'] ?? '—';
    final phone = data['phone'] ?? '—';

    final roleLabel =
        _roleLabels[role] ?? role.toUpperCase();
    final roleIcon  =
        _roleIcons[role]  ?? Icons.badge_rounded;
    final roleColor = _roleColors[role] ?? _kBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _kBlueBorder.withOpacity(0.5),
            width: 1),
        boxShadow: const [
          BoxShadow(
              color     : Color(0x0A1565C0),
              blurRadius: 10,
              offset    : Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role icon avatar
            Container(
              width : 48,
              height: 48,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  Icon(roleIcon, color: roleColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontSize  : 15,
                              fontWeight: FontWeight.w700,
                              color     : _kDark),
                          overflow:
                              TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(roleLabel,
                          style: TextStyle(
                              fontSize  : 11,
                              fontWeight: FontWeight.w700,
                              color     : roleColor)),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  _row(Icons.apartment_rounded,
                      hostel.toString().toUpperCase()),
                  const SizedBox(height: 2),
                  _row(Icons.phone_rounded, phone),
                  const SizedBox(height: 2),
                  _row(Icons.key_rounded, userId),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width : 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.red.shade100, width: 1),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 13, color: _kGrey),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize  : 12,
                    color     : _kGrey,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String     label;
  final bool       selected;
  final Color?     color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? _kBlue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? c : _kBlueBorder,
              width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color     : c.withOpacity(0.25),
                      blurRadius: 8,
                      offset    : const Offset(0, 3))
                ]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize  : 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _kGrey)),
      ),
    );
  }
}

// ── Add Staff Page ────────────────────────────────────────────────────────────
class AddStaffPage extends StatefulWidget {
  const AddStaffPage({super.key});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final _name    = TextEditingController();
  final _phone   = TextEditingController();
  final _email   = TextEditingController();
  final _staffId = TextEditingController();

  String? _role;
  String? _hostel;
  bool _saving = false;

  // ── Role classification helpers ───────────────────────────────────────────

  /// Principal & Warden → always 'common', no dropdown shown
  bool get _isCommonOnly =>
      _role != null && _commonOnlyRoles.contains(_role);

  /// Matron & RT → hostel dropdown shown but only Nila / Kabani
  bool get _isHostelSpecific =>
      _role != null && _hostelSpecificRoles.contains(_role);

  /// Security → full dropdown (Nila / Kabani / Common)
  bool get _needsHostelDropdown =>
      _role != null && !_isCommonOnly;

  List<Map<String, String>> get _availableHostels {
    if (_isHostelSpecific) {
      return [
        {'value': 'nila',   'label': 'Nila'},
        {'value': 'kabani', 'label': 'Kabani'},
      ];
    }
    // Security: all 3 options
    return _hostelOptions
        .map((e) => Map<String, String>.from(e))
        .toList();
  }

  // ── userId generation ─────────────────────────────────────────────────────
  String _buildUserId() {
    switch (_role) {
      case 'principal':
        return 'principal';          // single principal, fixed id
      case 'warden':
        return 'warden';             // single warden
      case 'security':
        return _hostel == 'common'
            ? 'security'
            : 'security@${_hostel!}';
      default:
        // matron, rt → hostel-specific
        return '${_role!}@${_hostel!}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_needsHostelDropdown && _hostel == null) {
      _showSnack('Please select a hostel.', Colors.red.shade600);
      return;
    }

    setState(() => _saving = true);

    try {
      final phone    = _phone.text.trim();
      final last4    = phone.substring(phone.length - 4);

      // For common-only roles hostel is always 'common'
      final hostelVal =
          _isCommonOnly ? 'common' : _hostel;

      final userId   = _buildUserId();
      final password = '${_role!}@$last4';

      await FirebaseFirestore.instance
          .collection('staff')
          .doc(userId)
          .set({
        'name'     : _name.text.trim(),
        'phone'    : phone,
        'email'    : _email.text.trim(),
        'staffId'  : _staffId.text.trim(),
        'role'     : _role,
        'hostel'   : hostelVal,
        'userId'   : userId,
        'password' : password,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _saving = false);
        _showSuccessDialog(userId, password);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showSnack('Error: $e', Colors.red.shade600);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccessDialog(String userId, String password) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width : 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle_rounded,
                color: Colors.green.shade600, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Staff Added!',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 17)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CredRow(label: 'User ID',   value: userId),
            const SizedBox(height: 8),
            _CredRow(label: 'Password', value: password),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _staffId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Staff Member',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ── Role selector ───────────────────────────────────────
            _SectionHeader(
                icon : Icons.badge_rounded,
                title: 'Role'),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount  : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing : 10,
              childAspectRatio: 2.8,
              shrinkWrap      : true,
              physics         :
                  const NeverScrollableScrollPhysics(),
              children: _roleLabels.entries.map((e) {
                final selected = _role == e.key;
                final color =
                    _roleColors[e.key] ?? _kBlue;
                final icon =
                    _roleIcons[e.key] ?? Icons.badge_rounded;
                return GestureDetector(
                  onTap: () => setState(() {
                    _role   = e.key;
                    _hostel = null; // reset on role change
                  }),
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected ? color : Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? color
                              : _kBlueBorder,
                          width: 1.2),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: color
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset:
                                      const Offset(0, 3))
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size : 16,
                            color: selected
                                ? Colors.white
                                : color),
                        const SizedBox(width: 6),
                        Text(e.value,
                            style: TextStyle(
                                fontSize  : 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : _kDark)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // ── Common-only info banner (Principal / Warden) ────────
            if (_isCommonOnly) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFA5D6A7),
                      width: 1),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF2E7D32), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_roleLabels[_role]} is a common role '
                      'and applies to both hostels.',
                      style: const TextStyle(
                          fontSize  : 13,
                          color     : Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
              ),
            ],

            // ── Hostel selector (only for non-common roles) ─────────
            if (_needsHostelDropdown) ...[
              const SizedBox(height: 24),
              _SectionHeader(
                  icon : Icons.apartment_rounded,
                  title: 'Hostel'),
              const SizedBox(height: 12),
              _FieldCard(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Row(children: [
                    Container(
                      width : 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _kBlueTint,
                        borderRadius:
                            BorderRadius.circular(9),
                      ),
                      child: const Icon(
                          Icons.apartment_rounded,
                          color: _kBlue,
                          size : 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _hostel,
                        decoration: const InputDecoration(
                          labelText: 'Select Hostel',
                          labelStyle: TextStyle(
                              fontSize: 13, color: _kGrey),
                          border        : InputBorder.none,
                          enabledBorder : InputBorder.none,
                          focusedBorder : InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12),
                        ),
                        items: _availableHostels
                            .map((h) =>
                                DropdownMenuItem<String>(
                                  value: h['value'],
                                  child: Text(h['label']!,
                                      style: const TextStyle(
                                          fontSize  : 14,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: _kDark)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _hostel = v),
                        validator: (v) => v == null
                            ? 'Please select a hostel'
                            : null,
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _kBlue),
                        dropdownColor: Colors.white,
                      ),
                    ),
                  ]),
                ),
              ]),
            ],

            const SizedBox(height: 24),

            // ── Staff details ───────────────────────────────────────
            _SectionHeader(
                icon : Icons.person_rounded,
                title: 'Staff Details'),
            const SizedBox(height: 12),
            _FieldCard(children: [
              _Field(
                controller: _name,
                label     : 'Full Name',
                icon      : Icons.person_rounded,
                validator : (v) =>
                    (v == null || v.isEmpty)
                        ? 'Name is required'
                        : null,
              ),
              _divider(),
              _Field(
                controller: _staffId,
                label     : 'Staff ID',
                icon      : Icons.badge_rounded,
                validator : (v) =>
                    (v == null || v.isEmpty)
                        ? 'Staff ID is required'
                        : null,
              ),
              _divider(),
              _Field(
                controller    : _phone,
                label         : 'Phone Number',
                icon          : Icons.phone_rounded,
                keyboardType  : TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) =>
                    (v == null || v.length != 10)
                        ? 'Enter a valid 10-digit number'
                        : null,
              ),
              _divider(),
              _Field(
                controller  : _email,
                label       : 'Email Address',
                icon        : Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Email is required';
                  }
                  if (!v.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 32),

            // ── Role not selected warning ────────────────────────────
            if (_role == null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.orange.shade700,
                      size : 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please select a role above to proceed.',
                      style: TextStyle(
                          fontSize  : 13,
                          color     : Colors.orange.shade700,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
              ),

            if (_role != null) ...[
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _kBlue.withOpacity(0.45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width : 22,
                          height: 22,
                          child : CircularProgressIndicator(
                              color      : Colors.white,
                              strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.person_add_rounded,
                                size: 20),
                            SizedBox(width: 8),
                            Text('Add Staff Member',
                                style: TextStyle(
                                    fontSize  : 16,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kBlue,
                  side: const BorderSide(
                      color: _kBlueBorder, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize  : 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  static Widget _divider() => const Divider(
      height: 1, indent: 56, color: Color(0xFFF0F4FF));
}

// ── Credential Row ────────────────────────────────────────────────────────────
class _CredRow extends StatelessWidget {
  final String label, value;
  const _CredRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _kBlueTint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBlueBorder, width: 1),
        ),
        child: Row(children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize  : 13,
                  color     : _kGrey,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize  : 13,
                    fontWeight: FontWeight.w700,
                    color     : _kDark),
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: () =>
                Clipboard.setData(ClipboardData(text: value)),
            child: const Icon(Icons.copy_rounded,
                size: 15, color: _kBlue),
          ),
        ]),
      );
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  const _SectionHeader(
      {required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16, color: _kBlue),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize     : 14,
                fontWeight   : FontWeight.w800,
                color        : _kDark,
                letterSpacing: -0.2)),
      ]);
}

// ── Field Card ────────────────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final List<Widget> children;
  const _FieldCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: _kBlueBorder.withOpacity(0.5), width: 1),
          boxShadow: const [
            BoxShadow(
                color     : Color(0x0A1565C0),
                blurRadius: 14,
                offset    : Offset(0, 4)),
          ],
        ),
        child: Column(children: children),
      );
}

// ── Editable Field ────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController          controller;
  final String                         label;
  final IconData                       icon;
  final TextInputType                  keyboardType;
  final List<TextInputFormatter>?      inputFormatters;
  final String? Function(String?)?     validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType    = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width : 32,
              height: 32,
              decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: _kBlue, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller     : controller,
                keyboardType   : keyboardType,
                inputFormatters: inputFormatters,
                validator      : validator,
                style: const TextStyle(
                    fontSize  : 14,
                    fontWeight: FontWeight.w600,
                    color     : _kDark),
                decoration: InputDecoration(
                  labelText : label,
                  labelStyle: const TextStyle(
                      fontSize: 13, color: _kGrey),
                  border            : InputBorder.none,
                  enabledBorder     : InputBorder.none,
                  focusedBorder     : InputBorder.none,
                  errorBorder       : InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding    : const EdgeInsets.symmetric(
                      vertical: 12),
                  errorStyle:
                      const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      );
}