import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue       = Color(0xFF1565C0);
const _kBlueTint   = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);
const _kBg         = Color(0xFFF5F8FF);
const _kDark       = Color(0xFF1A1A2E);
const _kGrey       = Color(0xFF6B7280);

class EditProfilePage extends StatefulWidget {
  final String admissionNo;
  final Map<String, dynamic> data;

  const EditProfilePage({
    super.key,
    required this.admissionNo,
    required this.data,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _parentPhone;
  late final TextEditingController _parentEmail;
  late final TextEditingController _room;
  late final TextEditingController _semester;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _email       = TextEditingController(text: widget.data['email']       ?? '');
    _phone       = TextEditingController(text: widget.data['phone']       ?? '');
    _parentPhone = TextEditingController(text: widget.data['parentPhone'] ?? '');
    _parentEmail = TextEditingController(text: widget.data['parentEmail'] ?? '');
    _room        = TextEditingController(
        text: '${widget.data['room'] ?? ''}');
    _semester    = TextEditingController(text: widget.data['semester']    ?? '');
  }

  @override
  void dispose() {
    _email.dispose(); _phone.dispose(); _parentPhone.dispose();
    _parentEmail.dispose(); _room.dispose(); _semester.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final phone = _phone.text.trim();
      // Auto-generate password from last 4 digits of phone
      final newPassword =
          'student@${phone.substring(phone.length - 4)}';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.admissionNo)
          .update({
        'email':       _email.text.trim(),
        'phone':       phone,
        'parentPhone': _parentPhone.text.trim(),
        'parentEmail': _parentEmail.text.trim(),
        'room':        int.tryParse(_room.text.trim()) ??
            widget.data['room'],
        'semester':    _semester.text.trim(),
        'password':    newPassword,
      });

      if (mounted) {
        _showSnack('Profile updated successfully!',
            Colors.green.shade600);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnack('Failed to save. Please try again.',
            Colors.red.shade600);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          color == Colors.green.shade600
              ? Icons.check_circle_rounded
              : Icons.error_rounded,
          color: Colors.white, size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ── Info banner ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _kBlueTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBlueBorder, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: _kBlue, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Name, Admission No., KTU ID & Department are '
                      'managed by the hostel admin and cannot be edited here.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _kBlue.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Read-only section ───────────────────────────────────
            _SectionHeader(
                icon: Icons.lock_rounded, title: 'Read-Only Details'),
            const SizedBox(height: 12),
            _ReadOnlyCard(items: {
              'Name'         : widget.data['name']        ?? '—',
              'Admission No.': widget.data['admissionNo'] ?? '—',
              'KTU ID'       : widget.data['ktuid']       ?? '—',
              'Department'   : widget.data['department']  ?? '—',
            }),

            const SizedBox(height: 24),

            // ── Student info ────────────────────────────────────────
            _SectionHeader(
                icon: Icons.person_rounded, title: 'Your Details'),
            const SizedBox(height: 14),

            _FieldCard(children: [
              _Field(
                controller: _email,
                label: 'Email Address',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              _divider(),
              _Field(
                controller: _phone,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (v == null || v.length != 10) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              _divider(),
              _Field(
                controller: _semester,
                label: 'Semester (e.g. S6)',
                icon: Icons.class_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Semester is required' : null,
              ),
              _divider(),
              _Field(
                controller: _room,
                label: 'Room Number',
                icon: Icons.door_front_door_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) =>
                    v == null || v.isEmpty ? 'Room number is required' : null,
              ),
            ]),

            const SizedBox(height: 20),

            // ── Parent info ─────────────────────────────────────────
            _SectionHeader(
                icon: Icons.family_restroom_rounded,
                title: 'Parent / Guardian Details'),
            const SizedBox(height: 14),

            _FieldCard(children: [
              _Field(
                controller: _parentPhone,
                label: 'Parent Phone',
                icon: Icons.phone_callback_rounded,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Parent phone is required';
                  if (v.length != 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              _divider(),
              _Field(
                controller: _parentEmail,
                label: 'Parent Email',
                icon: Icons.mark_email_read_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Parent email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 32),

            // ── Save button ─────────────────────────────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kBlue.withOpacity(0.45),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Save Changes', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kBlue,
                  side: const BorderSide(color: _kBlueBorder, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Cancel', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
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

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16, color: _kBlue),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800,
            color: _kDark, letterSpacing: -0.2)),
      ]);
}

// ── Read-Only Card ────────────────────────────────────────────────────────────
class _ReadOnlyCard extends StatelessWidget {
  final Map<String, String> items;
  const _ReadOnlyCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final keys = items.keys.toList();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E8F0), width: 1),
      ),
      child: Column(
        children: List.generate(keys.length, (i) {
          final k = keys[i];
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 11),
              child: Row(children: [
                Expanded(child: Text(k, style: const TextStyle(
                    fontSize: 13, color: _kGrey,
                    fontWeight: FontWeight.w500))),
                Text(items[k]!, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF))),
                const SizedBox(width: 8),
                const Icon(Icons.lock_outline_rounded,
                    size: 13, color: Color(0xFFD1D5DB)),
              ]),
            ),
            if (i < keys.length - 1)
              const Divider(height: 1, color: Color(0xFFEEF0F5)),
          ]);
        }),
      ),
    );
  }
}

// ── Field Card (groups multiple fields) ──────────────────────────────────────
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
                color: Color(0x0A1565C0),
                blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Column(children: children),
      );
}

// ── Single editable field row ─────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _kBlueTint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _kBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: _kDark),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                    fontSize: 13, color: _kGrey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                errorStyle: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}