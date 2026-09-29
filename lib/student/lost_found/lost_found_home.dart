import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_data.dart';

// ── App-wide theme constants (same as all other pages) ───────────────────────
const _kPrimary = Color(0xFF1565C0);
const _kDark = Color(0xFF0D47A1);
const _kAccent = Color(0xFF1E88E5);
const _kBg = Color(0xFFF4F6FB);
const _kTint = Color(0xFFE8F0FE);
const _kBorder = Color(0xFFE0E7F0);

class LostFoundHome extends StatefulWidget {
  const LostFoundHome({super.key});

  @override
  State<LostFoundHome> createState() => _LostFoundHomeState();
}

class _LostFoundHomeState extends State<LostFoundHome>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _db = FirebaseFirestore.instance;

  Uint8List? _selectedImage;
  bool _uploading = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _lostSearch = TextEditingController();
  final _foundSearch = TextEditingController();

  String _lostQuery = '';
  String _foundQuery = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _lostSearch.dispose();
    _foundSearch.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Uint8List? _safeBase64(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  bool _isRecent(dynamic ts) =>
      ts is Timestamp && DateTime.now().difference(ts.toDate()).inHours < 24;

  List<QueryDocumentSnapshot> _sorted(List<QueryDocumentSnapshot> docs) {
    docs.sort((a, b) {
      final aTs = (a.data() as Map)['date'] as Timestamp?;
      final bTs = (b.data() as Map)['date'] as Timestamp?;
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return bTs.compareTo(aTs);
    });
    return docs;
  }

  // ── Pick image ───────────────────────────────────────────────────────────────
  Future<void> _pickImage(VoidCallback refresh) async {
    final p = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (p == null) return;
    final bytes = await p.readAsBytes();
    setState(() => _selectedImage = bytes);
    refresh();
  }

  // ── Upload ───────────────────────────────────────────────────────────────────
  Future<bool> _isDuplicate(String title) async {
    final snap = await _db
        .collection('lost_items')
        .where('title', isEqualTo: title)
        .where('status', isEqualTo: 'lost')
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> _uploadLostItem() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty || desc.isEmpty || _selectedImage == null) {
      _snack('Please fill all fields and select an image', error: true);
      return;
    }
    setState(() => _uploading = true);
    if (await _isDuplicate(title)) {
      setState(() => _uploading = false);
      _snack('A similar item is already reported as lost', error: true);
      return;
    }
    await _db.collection('lost_items').add({
      'title': title,
      'description': desc,
      'image': base64Encode(_selectedImage!),
      'status': 'lost',
      'reportedBy': StudentData.name,
      'reportedRoom': StudentData.room,
      'reportedPhone': StudentData.phone,
      'foundBy': '',
      'foundRoom': '',
      'foundPhone': '',
      'date': Timestamp.now(),
    });
    _titleCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _selectedImage = null;
      _uploading = false;
    });
    if (!mounted) return;
    Navigator.pop(context);
    _snack('Lost item reported successfully!');
  }

  // ── Mark found ───────────────────────────────────────────────────────────────
  Future<void> _markFound(String id, String reportedBy) async {
    if (StudentData.name == reportedBy) {
      _snack('You cannot mark your own item as found', error: true);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: _kPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mark as Found?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'This will move the item to the Found tab with your contact details.',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF546E7A)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF607D8B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _db.collection('lost_items').doc(id).update({
      'status': 'found',
      'foundBy': StudentData.name,
      'foundRoom': StudentData.room,
      'foundPhone': StudentData.phone,
    });
    if (!mounted) return;
    _snack('Item marked as found! 🎉');
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: error
            ? const Color(0xFFD32F2F)
            : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────
  Widget _empty(String label) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_outlined, size: 56, color: Color(0xFFB0BEC5)),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 14.5),
        ),
      ],
    ),
  );

  // ── LOST GRID ────────────────────────────────────────────────────────────────
  Widget _lostGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('lost_items')
          .where('status', isEqualTo: 'lost')
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.hasError) return _empty('Something went wrong. Try again.');
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _kPrimary),
          );
        }
        final docs = _sorted(
          snap.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return (data['title'] ?? '').toString().toLowerCase().contains(
              _lostQuery,
            );
          }).toList(),
        );

        if (docs.isEmpty) {
          return _empty(
            _lostQuery.isEmpty
                ? 'No lost items reported yet'
                : 'No results for "$_lostQuery"',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.60,
          ),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final reporter = _nonEmpty(data['reportedBy']) ?? 'Unknown';
            final room = _nonEmpty(data['reportedRoom']) ?? '-';
            final phone = _nonEmpty(data['reportedPhone']) ?? '-';
            final recent = _isRecent(data['date']);

            return _LostCard(
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              imageBytes: _safeBase64(data['image']),
              reporter: reporter,
              room: room,
              phone: phone,
              isRecent: recent,
              onMarkFound: () => _markFound(docs[i].id, reporter),
            );
          },
        );
      },
    );
  }

  // ── FOUND GRID ───────────────────────────────────────────────────────────────
  Widget _foundGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('lost_items')
          .where('status', isEqualTo: 'found')
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.hasError) return _empty('Something went wrong. Try again.');
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _kPrimary),
          );
        }
        final docs = _sorted(
          snap.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return (data['title'] ?? '').toString().toLowerCase().contains(
              _foundQuery,
            );
          }).toList(),
        );

        if (docs.isEmpty) {
          return _empty(
            _foundQuery.isEmpty
                ? 'No found items yet'
                : 'No results for "$_foundQuery"',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.58,
          ),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _FoundCard(
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              imageBytes: _safeBase64(data['image']),
              reporter: _nonEmpty(data['reportedBy']) ?? 'Unknown',
              reporterRoom: _nonEmpty(data['reportedRoom']) ?? '-',
              reporterPhone: _nonEmpty(data['reportedPhone']) ?? '-',
              finder: _nonEmpty(data['foundBy']) ?? 'Unknown',
              finderRoom: _nonEmpty(data['foundRoom']) ?? '-',
              finderPhone: _nonEmpty(data['foundPhone']) ?? '-',
            );
          },
        );
      },
    );
  }

  // ── Report bottom sheet ──────────────────────────────────────────────────────
  void _openReportSheet() {
    setState(() {
      _selectedImage = null;
      _uploading = false;
    });
    _titleCtrl.clear();
    _descCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE3EE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Sheet title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.report_problem_outlined,
                      color: _kPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Report Lost Item',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Item name
              _sheetField(
                controller: _titleCtrl,
                label: 'Item Name',
                icon: Icons.label_outline_rounded,
              ),
              const SizedBox(height: 12),

              // Description
              _sheetField(
                controller: _descCtrl,
                label: 'Description',
                icon: Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // Image picker
              GestureDetector(
                onTap: () => _pickImage(() => setSheet(() {})),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 30,
                              color: const Color(0xFF90A4AE),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap to select image',
                              style: TextStyle(
                                color: Color(0xFFB0BEC5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 18),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _uploading ? null : _uploadLostItem,
                  icon: _uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    _uploading ? 'Submitting...' : 'Submit Lost Item',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kAccent, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    ),
  );

  // ── Search bar ───────────────────────────────────────────────────────────────
  Widget _searchBar(
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChanged,
  ) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder),
    ),
    child: TextField(
      controller: ctrl,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF90A4AE),
          size: 20,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
      ),
    ),
  );

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Gradient header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kDark, _kAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lost & Found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Report & track lost items',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tab bar
                  TabBar(
                    controller: _tab,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.search_off_rounded, size: 18),
                        text: 'Lost',
                      ),
                      Tab(
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        text: 'Found',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab content ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // Lost tab
                Column(
                  children: [
                    _searchBar(
                      _lostSearch,
                      'Search lost items...',
                      (v) => setState(() => _lostQuery = v.toLowerCase()),
                    ),
                    Expanded(child: _lostGrid()),
                  ],
                ),
                // Found tab
                Column(
                  children: [
                    _searchBar(
                      _foundSearch,
                      'Search found items...',
                      (v) => setState(() => _foundQuery = v.toLowerCase()),
                    ),
                    Expanded(child: _foundGrid()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openReportSheet,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Report Lost',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Lost item card ────────────────────────────────────────────────────────────
class _LostCard extends StatelessWidget {
  final String title, description, reporter, room, phone;
  final Uint8List? imageBytes;
  final bool isRecent;
  final VoidCallback onMarkFound;

  const _LostCard({
    required this.title,
    required this.description,
    required this.reporter,
    required this.room,
    required this.phone,
    required this.imageBytes,
    required this.isRecent,
    required this.onMarkFound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 110,
                      width: double.infinity,
                      color: const Color(0xFFF0F4F8),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 28,
                        color: Colors.blueGrey.shade200,
                      ),
                    ),
              if (isRecent)
                Positioned(
                  top: 7,
                  left: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57F17),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF78909C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Reporter info
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 11,
                        color: Color(0xFF90A4AE),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '$reporter · Rm $room',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF78909C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 11,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Mark found button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onMarkFound,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        backgroundColor: const Color(0xFFE8F5E9),
                        foregroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Mark as Found',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
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

// ── Found item card ───────────────────────────────────────────────────────────
class _FoundCard extends StatelessWidget {
  final String title, description;
  final String reporter, reporterRoom, reporterPhone;
  final String finder, finderRoom, finderPhone;
  final Uint8List? imageBytes;

  const _FoundCard({
    required this.title,
    required this.description,
    required this.reporter,
    required this.reporterRoom,
    required this.reporterPhone,
    required this.finder,
    required this.finderRoom,
    required this.finderPhone,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with FOUND badge
          Stack(
            children: [
              imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      width: double.infinity,
                      color: const Color(0xFFF0F4F8),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 28,
                        color: Colors.blueGrey.shade200,
                      ),
                    ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'FOUND',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF90A4AE),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Reporter box
                  _infoBox(
                    label: 'Lost by $reporter',
                    room: reporterRoom,
                    phone: reporterPhone,
                    bg: const Color(0xFFE3F2FD),
                    textColor: const Color(0xFF1565C0),
                    iconColor: const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 6),

                  // Finder box
                  _infoBox(
                    label: 'Found by $finder',
                    room: finderRoom,
                    phone: finderPhone,
                    bg: const Color(0xFFE8F5E9),
                    textColor: const Color(0xFF2E7D32),
                    iconColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required String label,
    required String room,
    required String phone,
    required Color bg,
    required Color textColor,
    required Color iconColor,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label · Rm $room',
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Icon(Icons.phone_outlined, size: 10, color: iconColor),
            const SizedBox(width: 3),
            Text(phone, style: TextStyle(fontSize: 10, color: iconColor)),
          ],
        ),
      ],
    ),
  );
}
