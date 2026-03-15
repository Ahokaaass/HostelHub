import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_data.dart';

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

  // ── Safe base64 decode ──
  Uint8List? _safeBase64Decode(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  // ── Treats empty string same as null ──
  String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  // ── Safe image widget with placeholder ──
  Widget _imageWidget(String? b64, {double height = 120}) {
    final bytes = _safeBase64Decode(b64);
    if (bytes == null) {
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade100,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 36,
          color: Colors.grey.shade400,
        ),
      );
    }
    return Image.memory(
      bytes,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  // ── Sort docs by date descending in Dart ──
  // IMPORTANT: This avoids the Firestore composite index error that occurs
  // when combining .where() + .orderBy() on different fields.
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

  // ── PICK IMAGE ──
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

  // ── DUPLICATE CHECK ──
  Future<bool> _isDuplicate(String title) async {
    final snap = await firestore
        .collection("lost_items")
        .where("title", isEqualTo: title)
        .where("status", isEqualTo: "lost")
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── UPLOAD LOST ITEM ──
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

  // ── MARK FOUND ──
  Future<void> _markFound(String id, String reportedBy) async {
    if (StudentData.name == reportedBy) {
      _showSnack("You cannot mark your own item as found", isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Mark as Found?"),
        content: const Text(
          "This will move the item to the Found tab with your contact details.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
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
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── EMPTY STATE ──
  Widget _emptyState(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── LOST GRID ──
  Widget _lostGrid() {
    return StreamBuilder<QuerySnapshot>(
      // NO .orderBy() — avoids Firestore composite index requirement.
      // Sorting is handled in Dart via _sortedDocs().
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
          return const Center(child: CircularProgressIndicator());
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

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.60,
          ),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final reporter = _nonEmpty(data["reportedBy"]) ?? "Unknown";
            final room = _nonEmpty(data["reportedRoom"]) ?? "-";
            final phone = _nonEmpty(data["reportedPhone"]) ?? "-";
            final recent = _isRecent(data["date"]);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _imageWidget(data["image"]),
                      if (recent)
                        Positioned(
                          top: 7,
                          left: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "NEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["title"] ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            data["description"] ?? "",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 11,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  "$reporter · Rm $room",
                                  style: const TextStyle(fontSize: 10),
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
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                phone,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                backgroundColor: Colors.green.shade50,
                                foregroundColor: Colors.green.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _markFound(docs[i].id, reporter),
                              child: const Text(
                                "Mark as Found",
                                style: TextStyle(fontSize: 11),
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
          },
        );
      },
    );
  }

  // ── FOUND GRID ──
  Widget _foundGrid() {
    return StreamBuilder<QuerySnapshot>(
      // NO .orderBy() — avoids composite index error
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
          return const Center(child: CircularProgressIndicator());
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

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.58,
          ),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final reporter = _nonEmpty(data["reportedBy"]) ?? "Unknown";
            final reporterRoom = _nonEmpty(data["reportedRoom"]) ?? "-";
            final reporterPhone = _nonEmpty(data["reportedPhone"]) ?? "-";
            final finder = _nonEmpty(data["foundBy"]) ?? "Unknown";
            final finderRoom = _nonEmpty(data["foundRoom"]) ?? "-";
            final finderPhone = _nonEmpty(data["foundPhone"]) ?? "-";

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _imageWidget(data["image"]),
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "FOUND",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["title"] ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            data["description"] ?? "",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Reporter info box
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Lost by $reporter · Rm $reporterRoom",
                                  style: const TextStyle(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 10,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      reporterPhone,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Finder info box
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Found by $finder · Rm $finderRoom",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 10,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      finderPhone,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
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
          },
        );
      },
    );
  }

  // ── UPLOAD BOTTOM SHEET ──
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Report Lost Item",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Item Name",
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _pickImage(() => setSheet(() {})),
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 32,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Tap to select image",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                          : const Icon(Icons.upload_rounded),
                      label: Text(
                        _uploading ? "Submitting..." : "Submit Lost Item",
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Lost"),
            Tab(text: "Found"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadDialog,
        icon: const Icon(Icons.add),
        label: const Text("Report Lost"),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: TextField(
                  controller: lostSearch,
                  decoration: InputDecoration(
                    hintText: "Search lost items...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => lostQuery = v.toLowerCase()),
                ),
              ),
              Expanded(child: _lostGrid()),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: TextField(
                  controller: foundSearch,
                  decoration: InputDecoration(
                    hintText: "Search found items...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) =>
                      setState(() => foundQuery = v.toLowerCase()),
                ),
              ),
              Expanded(child: _foundGrid()),
            ],
          ),
        ],
      ),
    );
  }
}
