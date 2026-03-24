import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_data.dart';

const _kBlue = Color(0xFF1565C0);
const _kBlueTint = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);
const _kBg = Color(0xFFF5F8FF);
const _kCard = Colors.white;
const _kTextDark = Color(0xFF1A1A2E);
const _kTextMid = Color(0xFF6B7280);
const _kTextLight = Color(0xFF9CA3AF);

class LostFoundHome extends StatefulWidget {
  const LostFoundHome({super.key});

  @override
  State<LostFoundHome> createState() => _LostFoundHomeState();
}

class _LostFoundHomeState extends State<LostFoundHome>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final firestore = FirebaseFirestore.instance;

  Uint8List? selectedImage;
  bool _uploading = false;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final lostSearch = TextEditingController();
  final foundSearch = TextEditingController();

  String lostQuery = "";
  String foundQuery = "";

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    titleController.dispose();
    descController.dispose();
    lostSearch.dispose();
    foundSearch.dispose();
    super.dispose();
  }

  // Safe base64 decode — never throws, returns null on bad/empty data
  Uint8List? _safeBase64Decode(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  // Treats empty string same as null
  String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  // Safe image widget — shows placeholder if image is missing or corrupt
  Widget _imageWidget(String? b64, {double height = 110}) {
    final bytes = _safeBase64Decode(b64);
    if (bytes == null) {
      return Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFF0F4FF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 28, color: _kTextLight),
            const SizedBox(height: 4),
            Text(
              'No image',
              style: TextStyle(fontSize: 10, color: _kTextLight),
            ),
          ],
        ),
      );
    }
    return Image.memory(
      bytes,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }

  // Sort by date descending client-side — avoids Firestore composite index error
  List<QueryDocumentSnapshot> _sortedDocs(List<QueryDocumentSnapshot> docs) {
    docs.sort((a, b) {
      final aTs = (a.data() as Map)["date"] as Timestamp?;
      final bTs = (b.data() as Map)["date"] as Timestamp?;
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return bTs.compareTo(aTs);
    });
    return docs;
  }

  bool _isRecent(dynamic ts) {
    if (ts == null || ts is! Timestamp) return false;
    return DateTime.now().difference(ts.toDate()).inHours < 24;
  }

  Future<void> _pickImage(VoidCallback refresh) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => selectedImage = bytes);
    refresh();
  }

  Future<bool> _isDuplicate(String title) async {
    final snap = await firestore
        .collection("lost_items")
        .where("title", isEqualTo: title)
        .where("status", isEqualTo: "lost")
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> _uploadLostItem() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();

    if (title.isEmpty || desc.isEmpty || selectedImage == null) {
      _showSnack("Please fill all fields and select an image", isError: true);
      return;
    }

    setState(() => _uploading = true);

    if (await _isDuplicate(title)) {
      setState(() => _uploading = false);
      _showSnack("A similar item is already reported as lost", isError: true);
      return;
    }

    await firestore.collection("lost_items").add({
      "title": title,
      "description": desc,
      "image": base64Encode(selectedImage!),
      "status": "lost",
      "reportedBy": StudentData.name,
      "reportedRoom": StudentData.room,
      "reportedPhone": StudentData.phone,
      "foundBy": "",
      "foundRoom": "",
      "foundPhone": "",
      "date": Timestamp.now(),
    });

    titleController.clear();
    descController.clear();
    setState(() {
      selectedImage = null;
      _uploading = false;
    });

    if (!mounted) return;
    Navigator.pop(context);
    _showSnack("Lost item reported successfully!");
  }

  Future<void> _markFound(String id, String reportedBy) async {
    if (StudentData.name == reportedBy) {
      _showSnack("You cannot mark your own item as found", isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Mark as Found?",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "This will move the item to the Found tab and attach your contact details.",
                style: TextStyle(fontSize: 13, color: _kTextMid, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _kBlueBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: _kTextMid),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text("Confirm"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    await firestore.collection("lost_items").doc(id).update({
      "status": "found",
      "foundBy": StudentData.name,
      "foundRoom": StudentData.room,
      "foundPhone": StudentData.phone,
    });

    if (!mounted) return;
    _showSnack("Item marked as found! 🎉");
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFB71C1C)
            : const Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _emptyState(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kBlueTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 34, color: _kBlue.withOpacity(0.5)),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: _kTextMid,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBlueBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081565C0),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: _kTextDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: _kTextLight),
          prefixIcon: Icon(Icons.search_rounded, color: _kTextLight, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // ── LOST GRID ─────────────────────────────────────────────────────────────────
  // FIX: Replaced GridView with fixed mainAxisExtent (caused overflow on mobile)
  // with a ListView of IntrinsicHeight rows (2 cards per row).
  // IntrinsicHeight makes both cards in a row equally tall, matching the taller one,
  // so no card ever clips/overflows its content.
  Widget _lostGrid() {
    return StreamBuilder<QuerySnapshot>(
      // No .orderBy() — avoids Firestore composite index requirement
      stream: firestore
          .collection("lost_items")
          .where("status", isEqualTo: "lost")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _emptyState(
            "Something went wrong. Try again later.",
            Icons.wifi_off_rounded,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kBlue));
        }

        final docs = _sortedDocs(
          snapshot.data!.docs.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return (d["title"] ?? "").toString().toLowerCase().contains(
              lostQuery,
            );
          }).toList(),
        );

        if (docs.isEmpty) {
          return _emptyState(
            lostQuery.isEmpty
                ? "No lost items reported yet"
                : 'No results for "$lostQuery"',
            Icons.search_off_rounded,
          );
        }

        // Build pairs of cards as rows
        final rows = <Widget>[];
        for (int i = 0; i < docs.length; i += 2) {
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _lostCard(docs[i]),
                  const SizedBox(width: 14),
                  i + 1 < docs.length
                      ? _lostCard(docs[i + 1])
                      : const Expanded(child: SizedBox()),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) => rows[i],
        );
      },
    );
  }

  Widget _lostCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final reporter = _nonEmpty(data["reportedBy"]) ?? "Unknown";
    final room = _nonEmpty(data["reportedRoom"]) ?? "-";
    final phone = _nonEmpty(data["reportedPhone"]) ?? "-";
    final recent = _isRecent(data["date"]);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDF5), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1565C0),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // shrink-wrap: no fixed height needed
          children: [
            // Image + badge
            Stack(
              children: [
                _imageWidget(data["image"], height: 110),
                if (recent)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6D00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 3, color: const Color(0xFFFF6D00)),
                ),
              ],
            ),

            // Text content — fully dynamic, no Spacer/Expanded inside
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data["title"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _kTextDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data["description"] ?? "",
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kTextMid,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Reporter info box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _kBlueTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 10,
                              color: _kBlue.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "$reporter · Rm $room",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _kBlue.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 10, color: _kBlue),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                phone,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _kBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _markFound(doc.id, reporter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Mark as Found",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FOUND GRID ────────────────────────────────────────────────────────────────
  // Same approach: ListView + IntrinsicHeight rows
  Widget _foundGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection("lost_items")
          .where("status", isEqualTo: "found")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _emptyState(
            "Something went wrong. Try again later.",
            Icons.wifi_off_rounded,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kBlue));
        }

        final docs = _sortedDocs(
          snapshot.data!.docs.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return (d["title"] ?? "").toString().toLowerCase().contains(
              foundQuery,
            );
          }).toList(),
        );

        if (docs.isEmpty) {
          return _emptyState(
            foundQuery.isEmpty
                ? "No found items yet"
                : 'No results for "$foundQuery"',
            Icons.search_off_rounded,
          );
        }

        final rows = <Widget>[];
        for (int i = 0; i < docs.length; i += 2) {
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _foundCard(docs[i]),
                  const SizedBox(width: 14),
                  i + 1 < docs.length
                      ? _foundCard(docs[i + 1])
                      : const Expanded(child: SizedBox()),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) => rows[i],
        );
      },
    );
  }

  Widget _foundCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final reporter = _nonEmpty(data["reportedBy"]) ?? "Unknown";
    final reporterRoom = _nonEmpty(data["reportedRoom"]) ?? "-";
    final reporterPhone = _nonEmpty(data["reportedPhone"]) ?? "-";
    final finder = _nonEmpty(data["foundBy"]) ?? "Unknown";
    final finderRoom = _nonEmpty(data["foundRoom"]) ?? "-";
    final finderPhone = _nonEmpty(data["foundPhone"]) ?? "-";

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDF5), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1565C0),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                _imageWidget(data["image"], height: 110),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "FOUND",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 3, color: const Color(0xFF2E7D32)),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data["title"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _kTextDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data["description"] ?? "",
                    style: const TextStyle(fontSize: 11, color: _kTextMid),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _contactBox(
                    label: "Lost by",
                    name: reporter,
                    room: reporterRoom,
                    phone: reporterPhone,
                    bgColor: _kBlueTint,
                    textColor: _kBlue,
                  ),
                  const SizedBox(height: 6),
                  _contactBox(
                    label: "Found by",
                    name: finder,
                    room: finderRoom,
                    phone: finderPhone,
                    bgColor: const Color(0xFFE8F5E9),
                    textColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactBox({
    required String label,
    required String name,
    required String room,
    required String phone,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: textColor.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 10,
                color: textColor.withOpacity(0.8),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  "$name · Rm $room",
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 10,
                color: textColor.withOpacity(0.8),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  phone,
                  style: TextStyle(fontSize: 10, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Upload bottom sheet ───────────────────────────────────────────────────────
  void _openUploadDialog() {
    setState(() {
      selectedImage = null;
      _uploading = false;
    });
    titleController.clear();
    descController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheet) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _kBlueTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.report_outlined,
                            color: _kBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Report Lost Item",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _kTextDark,
                              ),
                            ),
                            Text(
                              "Fill in details about the lost item",
                              style: TextStyle(fontSize: 12, color: _kTextMid),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sheetLabel("Item Name"),
                    const SizedBox(height: 6),
                    _sheetTextField(
                      controller: titleController,
                      hint: "e.g. Blue water bottle",
                      icon: Icons.label_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _sheetLabel("Description"),
                    const SizedBox(height: 6),
                    _sheetTextField(
                      controller: descController,
                      hint: "Describe the item in detail...",
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    _sheetLabel("Photo"),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _pickImage(() => setSheet(() {})),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 110,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedImage != null
                              ? Colors.transparent
                              : _kBlueTint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedImage != null
                                ? _kBlue
                                : _kBlueBorder,
                            width: selectedImage != null ? 2 : 1.5,
                          ),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: _kBlue,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 28,
                                    color: _kBlue.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Tap to add photo",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _kBlue.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _uploading ? null : _uploadLostItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _uploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.upload_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Submit Lost Item",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _sheetLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: _kTextDark,
      letterSpacing: 0.2,
    ),
  );

  Widget _sheetTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBlueBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: _kTextDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: _kTextLight),
          prefixIcon: Icon(icon, color: _kTextMid, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1 ? 12 : 0,
            horizontal: maxLines > 1 ? 14 : 0,
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lost & Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              "Hostel item recovery board",
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(3),
              labelColor: _kBlue,
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Lost Items"),
                Tab(text: "Found Items"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadDialog,
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          "Report Lost",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Column(
            children: [
              _searchBar(
                lostSearch,
                "Search lost items...",
                (v) => setState(() => lostQuery = v.toLowerCase()),
              ),
              Expanded(child: _lostGrid()),
            ],
          ),
          Column(
            children: [
              _searchBar(
                foundSearch,
                "Search found items...",
                (v) => setState(() => foundQuery = v.toLowerCase()),
              ),
              Expanded(child: _foundGrid()),
            ],
          ),
        ],
      ),
    );
  }
}
