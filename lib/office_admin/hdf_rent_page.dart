import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);
const _kGreen     = Color(0xFF2E7D32);
const _kGreenBg   = Color(0xFFE8F5E9);

// ── Model ─────────────────────────────────────────────────────────────────────
class _MonthEntry {
  final String monthId;   // "2025-03"
  final String label;     // "March 2025"
  final int    month;
  final int    year;
  bool hdf;
  bool rent;

  _MonthEntry({
    required this.monthId,
    required this.label,
    required this.month,
    required this.year,
    this.hdf  = false,
    this.rent = false,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────
class HdfRentPage extends StatefulWidget {
  const HdfRentPage({super.key});

  @override
  State<HdfRentPage> createState() => _HdfRentPageState();
}

class _HdfRentPageState extends State<HdfRentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ── Student search ─────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String _query = '';

  // ── Selected student ───────────────────────────────────────────────────────
  DocumentSnapshot? _selectedStudent;

  // ── Year shown in payments tab ─────────────────────────────────────────────
  late int _viewYear;
  List<_MonthEntry> _months = [];
  bool _loadingMonths = false;

  // ── Saving state ───────────────────────────────────────────────────────────
  bool _saving = false;

  // ── Dirty tracking: months changed since last save ─────────────────────────
  // We store original DB values to know what changed
  final Map<String, _MonthEntry> _originalValues = {};

  @override
  void initState() {
    super.initState();
    _viewYear = DateTime.now().year;
    _tab      = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Build 12 months list for _viewYear ─────────────────────────────────────
  List<_MonthEntry> _buildMonths(int year) {
    return List.generate(12, (i) {
      final dt = DateTime(year, i + 1);
      return _MonthEntry(
        monthId: DateFormat('yyyy-MM').format(dt),
        label  : DateFormat('MMMM yyyy').format(dt),
        month  : i + 1,
        year   : year,
      );
    });
  }

  // ── Load DB values for current year + student ──────────────────────────────
  Future<void> _loadYear(int year) async {
    if (_selectedStudent == null) return;
    setState(() => _loadingMonths = true);

    final entries = _buildMonths(year);
    _originalValues.clear();

    for (final m in entries) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedStudent!.id)
          .collection('budgets')
          .doc(m.monthId)
          .get();
      if (doc.exists) {
        m.hdf  = doc.data()?['hdfPaid']  ?? false;
        m.rent = doc.data()?['rentPaid'] ?? false;
      }
      // Store snapshot of original
      _originalValues[m.monthId] = _MonthEntry(
        monthId: m.monthId,
        label  : m.label,
        month  : m.month,
        year   : m.year,
        hdf    : m.hdf,
        rent   : m.rent,
      );
    }

    setState(() {
      _months      = entries;
      _loadingMonths = false;
    });
  }

  void _changeYear(int delta) {
    _viewYear += delta;
    _loadYear(_viewYear);
  }

  // ── Save all 12 months (batch write) ───────────────────────────────────────
  Future<void> _saveAll() async {
    if (_selectedStudent == null) return;

    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _saving = true);

    try {
      final sData = _selectedStudent!.data() as Map<String, dynamic>;
      final batch = FirebaseFirestore.instance.batch();

      for (final m in _months) {
        final ref = FirebaseFirestore.instance
            .collection('users')
            .doc(_selectedStudent!.id)
            .collection('budgets')
            .doc(m.monthId);

        batch.set(ref, {
          'month'      : DateFormat('MMMM').format(DateTime(m.year, m.month)),
          'year'       : m.year,
          'hdfPaid'    : m.hdf,
          'rentPaid'   : m.rent,
          'admissionNo': sData['admissionNo'] ?? _selectedStudent!.id,
          'name'       : sData['name']        ?? '',
          'phone'      : sData['parentPhone'] ?? '',
          'updatedAt'  : Timestamp.now(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      // Refresh original values after save
      for (final m in _months) {
        _originalValues[m.monthId] = _MonthEntry(
          monthId: m.monthId,
          label  : m.label,
          month  : m.month,
          year   : m.year,
          hdf    : m.hdf,
          rent   : m.rent,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content        : Text('$_viewYear saved successfully ✓'),
        backgroundColor: _kGreen,
        behavior       : SnackBarBehavior.floating,
        shape          : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration       : const Duration(seconds: 2),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content        : Text('Error saving: $e'),
        backgroundColor: Colors.red,
        behavior       : SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Count unsaved changes ──────────────────────────────────────────────────
  int get _changedCount {
    int count = 0;
    for (final m in _months) {
      final orig = _originalValues[m.monthId];
      if (orig == null) { count++; continue; }
      if (orig.hdf != m.hdf || orig.rent != m.rent) count++;
    }
    return count;
  }

  Future<bool> _showConfirmDialog() async {
    final changed = _months
        .where((m) {
          final orig = _originalValues[m.monthId];
          if (orig == null) return m.hdf || m.rent;
          return orig.hdf != m.hdf || orig.rent != m.rent;
        })
        .toList();

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor : Colors.white,
            surfaceTintColor: Colors.white,
            shape           : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Save $_viewYear Payments?',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize  : 17,
                  color     : _kText),
            ),
            content: changed.isEmpty
                ? const Text('No changes to save.',
                    style: TextStyle(color: _kSubtext))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${changed.length} month(s) have changes:',
                        style: const TextStyle(
                            color    : _kSubtext,
                            fontSize : 13),
                      ),
                      const SizedBox(height: 10),
                      ...changed.map((m) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(m.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize  : 13,
                                          color     : _kText)),
                                ),
                                _StatusBadge(
                                    label: 'HDF', paid: m.hdf),
                                const SizedBox(width: 6),
                                _StatusBadge(
                                    label: 'Rent', paid: m.rent),
                              ],
                            ),
                          )),
                    ],
                  ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: _kSubtext)),
              ),
              if (changed.isNotEmpty)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: Colors.white,
                    elevation      : 0,
                    shape          : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save All'),
                ),
            ],
          ),
        ) ??
        false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body           : Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(),

          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              physics   : const NeverScrollableScrollPhysics(),
              children  : [
                _buildStudentTab(),
                _buildPaymentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width      : double.infinity,
      decoration : const BoxDecoration(
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
              offset    : Offset(0, 6)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child : Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child  : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children          : [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width : 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color       : Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(11),
                        border      : Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children          : [
                      Text('HDF & Rent Tracker',
                          style: TextStyle(
                              color        : Colors.white,
                              fontSize     : 20,
                              fontWeight   : FontWeight.w800,
                              letterSpacing: -0.3)),
                      SizedBox(height: 2),
                      Text('Select student → mark → submit',
                          style: TextStyle(
                              color  : Colors.white70,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TabBar(
                controller           : _tab,
                indicatorColor       : Colors.white,
                indicatorWeight      : 3,
                labelStyle           : const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle : const TextStyle(
                    fontWeight: FontWeight.w500),
                labelColor           : Colors.white,
                unselectedLabelColor : Colors.white60,
                tabs                 : const [
                  Tab(text: '① Select Student'),
                  Tab(text: '② Mark Payments'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Student search + list ──────────────────────────────────────────
  Widget _buildStudentTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child  : Container(
            decoration: BoxDecoration(
              color       : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border      : Border.all(color: _kBorder),
              boxShadow   : const [
                BoxShadow(
                    color     : Color(0x0A1565C0),
                    blurRadius: 8,
                    offset    : Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller : _searchCtrl,
              decoration : InputDecoration(
                hintText      : 'Search by name or admission no…',
                hintStyle     : const TextStyle(
                    color: _kSubtext, fontSize: 14),
                prefixIcon    : const Icon(Icons.search_rounded,
                    color: _kSubtext, size: 20),
                suffixIcon    : _query.isNotEmpty
                    ? IconButton(
                        icon     : const Icon(Icons.clear_rounded,
                            color: _kSubtext, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border        : InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),

        // Student list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('name')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: _kBlue));
              }
              final all      = snap.data?.docs ?? [];
              final filtered = _query.isEmpty
                  ? all
                  : all.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final n    = (data['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final a    = (data['admissionNo'] ?? '')
                          .toString()
                          .toLowerCase();
                      return n.contains(_query) || a.contains(_query);
                    }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children    : [
                      const Icon(Icons.person_off_rounded,
                          color: _kSubtext, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        _query.isEmpty
                            ? 'No students found'
                            : 'No results for "$_query"',
                        style: const TextStyle(color: _kSubtext),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding    : const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount  : filtered.length,
                itemBuilder: (_, i) {
                  final d    = filtered[i];
                  final data = d.data() as Map<String, dynamic>;
                  final name = data['name']        ?? '';
                  final adm  = data['admissionNo'] ?? d.id;
                  final sel  = _selectedStudent?.id == d.id;

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedStudent = d;
                        _months          = [];
                      });
                      await _loadYear(_viewYear);
                      _tab.animateTo(1);
                    },
                    child: Container(
                      margin    : const EdgeInsets.only(bottom: 10),
                      padding   : const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color       : sel ? _kBlueTint : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border      : Border.all(
                            color: sel ? _kBlue : _kBorder,
                            width: sel ? 1.8 : 1.2),
                        boxShadow   : const [
                          BoxShadow(
                              color     : Color(0x0A1565C0),
                              blurRadius: 8,
                              offset    : Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width : 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color       : sel ? _kBlue : _kBlueTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color     : sel
                                        ? Colors.white
                                        : _kBlue,
                                    fontWeight: FontWeight.w800,
                                    fontSize  : 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize  : 14,
                                        color     : sel
                                            ? _kBlue
                                            : _kText)),
                                const SizedBox(height: 2),
                                Text('Adm: $adm',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color   : _kSubtext)),
                              ],
                            ),
                          ),
                          Icon(
                            sel
                                ? Icons.check_circle_rounded
                                : Icons.chevron_right_rounded,
                            color: sel ? _kBlue : _kSubtext,
                            size : 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Payment marking ────────────────────────────────────────────────
  Widget _buildPaymentTab() {
    if (_selectedStudent == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children    : [
            Container(
              width      : 64,
              height     : 64,
              decoration : BoxDecoration(
                  color       : _kBlueTint,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.person_search_rounded,
                  color: _kBlue, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('No student selected',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 15,
                    color     : _kText)),
            const SizedBox(height: 6),
            const Text('Please select a student first',
                style: TextStyle(color: _kSubtext, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _tab.animateTo(0),
              icon : const Icon(Icons.person_search_rounded, size: 18),
              label: const Text('Go to Select Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
                elevation      : 0,
                shape          : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final sData = _selectedStudent!.data() as Map<String, dynamic>;
    final sName = sData['name']        ?? '';
    final sAdm  = sData['admissionNo'] ?? _selectedStudent!.id;

    return Column(
      children: [
        // ── Student info banner ──────────────────────────────────────
        Container(
          margin : const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color       : _kBlueTint,
            borderRadius: BorderRadius.circular(14),
            border      : Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width : 38,
                height: 38,
                decoration: BoxDecoration(
                    color       : _kBlue,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    sName.isNotEmpty ? sName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color     : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize  : 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize  : 14,
                            color     : _kText)),
                    Text('Adm: $sAdm',
                        style: const TextStyle(
                            fontSize: 11, color: _kSubtext)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _tab.animateTo(0),
                style    : TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6)),
                child: const Text('Change',
                    style: TextStyle(
                        color     : _kBlue,
                        fontWeight: FontWeight.w700,
                        fontSize  : 12)),
              ),
            ],
          ),
        ),

        // ── Year navigator ───────────────────────────────────────────
        Container(
          margin : const EdgeInsets.fromLTRB(20, 12, 20, 0),
          padding: const EdgeInsets.symmetric(
              horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color       : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border      : Border.all(color: _kBorder),
            boxShadow   : const [
              BoxShadow(
                  color     : Color(0x0A1565C0),
                  blurRadius: 8,
                  offset    : Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              // Prev year
              _YearNavBtn(
                icon   : Icons.chevron_left_rounded,
                onTap  : () => _changeYear(-1),
              ),
              // Year label
              Expanded(
                child: GestureDetector(
                  onTap: _pickYear,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: _kBlue, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        '$_viewYear',
                        style: const TextStyle(
                            fontSize  : 17,
                            fontWeight: FontWeight.w800,
                            color     : _kText),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: _kSubtext, size: 16),
                    ],
                  ),
                ),
              ),
              // Next year
              _YearNavBtn(
                icon : Icons.chevron_right_rounded,
                onTap: () => _changeYear(1),
              ),
            ],
          ),
        ),

        // ── Legend ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child  : Row(
            children: [
              _LegendDot(color: _kGreen,   label: 'Paid'),
              const SizedBox(width: 12),
              _LegendDot(color: Colors.red.shade400, label: 'Not Paid'),
              const Spacer(),
              if (_changedCount > 0)
                Container(
                  padding   : const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color       : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                    border      : Border.all(
                        color: const Color(0xFFFFB300)),
                  ),
                  child: Text(
                    '$_changedCount unsaved',
                    style: const TextStyle(
                        fontSize  : 11,
                        fontWeight: FontWeight.w700,
                        color     : Color(0xFFE65100)),
                  ),
                ),
            ],
          ),
        ),

        // ── Month grid ────────────────────────────────────────────────
        Expanded(
          child: _loadingMonths
              ? const Center(
                  child: CircularProgressIndicator(color: _kBlue))
              : ListView.builder(
                  padding    : const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  itemCount  : _months.length,
                  itemBuilder: (_, i) => _MonthRow(
                    entry    : _months[i],
                    original : _originalValues[_months[i].monthId],
                    onChanged: () => setState(() {}),
                  ),
                ),
        ),

        // ── Always-visible Submit button ──────────────────────────────
        Container(
          padding   : const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color    : Colors.white,
            boxShadow: [
              BoxShadow(
                color     : Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset    : const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width : double.infinity,
            height: 52,
            child : ElevatedButton.icon(
              onPressed: _saving ? null : _saveAll,
              icon : _saving
                  ? const SizedBox(
                      width : 18,
                      height: 18,
                      child : CircularProgressIndicator(
                          strokeWidth: 2,
                          color      : Colors.white))
                  : const Icon(Icons.save_rounded, size: 20),
              label: Text(
                _saving
                    ? 'Saving…'
                    : _changedCount > 0
                        ? 'Submit Changes ($_changedCount)'
                        : 'Submit $_viewYear',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    _kBlue.withOpacity(0.6),
                elevation: 0,
                shape    : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Year picker dialog ────────────────────────────────────────────────────
  Future<void> _pickYear() async {
    int temp = _viewYear;
    final result = await showDialog<int>(
      context: context,
      builder : (_) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          backgroundColor : Colors.white,
          surfaceTintColor: Colors.white,
          shape           : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Year',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize  : 17,
                  color     : _kText)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setInner(() => temp--),
                icon     : const Icon(Icons.remove_circle_outline_rounded,
                    color: _kBlue),
              ),
              const SizedBox(width: 8),
              Text('$temp',
                  style: const TextStyle(
                      fontSize  : 26,
                      fontWeight: FontWeight.w800,
                      color     : _kText)),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setInner(() => temp++),
                icon     : const Icon(Icons.add_circle_outline_rounded,
                    color: _kBlue),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child    : const Text('Cancel',
                  style: TextStyle(color: _kSubtext)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, temp),
              style    : ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
                elevation      : 0,
                shape          : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Go'),
            ),
          ],
        ),
      ),
    );
    if (result != null && result != _viewYear) {
      _viewYear = result;
      await _loadYear(_viewYear);
    }
  }
}

// ── Month row widget ──────────────────────────────────────────────────────────
class _MonthRow extends StatefulWidget {
  final _MonthEntry  entry;
  final _MonthEntry? original;
  final VoidCallback onChanged;

  const _MonthRow({
    required this.entry,
    required this.original,
    required this.onChanged,
  });

  @override
  State<_MonthRow> createState() => _MonthRowState();
}

class _MonthRowState extends State<_MonthRow> {
  bool get _isDirty {
    final o = widget.original;
    if (o == null) return widget.entry.hdf || widget.entry.rent;
    return o.hdf != widget.entry.hdf || o.rent != widget.entry.rent;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.entry;
    // Short month name for badge
    final shortMonth = DateFormat('MMM')
        .format(DateTime(m.year, m.month));

    return Container(
      margin    : const EdgeInsets.only(bottom: 10),
      padding   : const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color       : _isDirty
            ? const Color(0xFFFFFDE7)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border      : Border.all(
          color: _isDirty
              ? const Color(0xFFFFB300)
              : _kBorder,
          width: _isDirty ? 1.5 : 1.2,
        ),
        boxShadow: const [
          BoxShadow(
              color     : Color(0x0A1565C0),
              blurRadius: 8,
              offset    : Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Month badge
          Container(
            width : 46,
            height: 46,
            decoration: BoxDecoration(
              color       : _kBlueTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(shortMonth,
                      style: const TextStyle(
                          fontSize  : 11,
                          fontWeight: FontWeight.w800,
                          color     : _kBlue)),
                  Text('${m.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 9,
                          color   : _kSubtext)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Month name + dirty indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('MMMM').format(
                          DateTime(m.year, m.month)),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 14,
                          color     : _kText),
                    ),
                    if (_isDirty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding   : const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color       : const Color(0xFFFFB300)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('edited',
                            style: TextStyle(
                                fontSize  : 9,
                                fontWeight: FontWeight.w700,
                                color     : Color(0xFFE65100))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${m.hdf ? "HDF ✓" : "HDF —"}  ·  ${m.rent ? "Rent ✓" : "Rent —"}',
                  style: TextStyle(
                      fontSize: 11,
                      color   : _isDirty
                          ? const Color(0xFFE65100)
                          : _kSubtext),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // HDF toggle
          _ToggleBtn(
            label  : 'HDF',
            paid   : m.hdf,
            onTap  : () {
              setState(() => m.hdf = !m.hdf);
              widget.onChanged();
            },
          ),
          const SizedBox(width: 8),

          // Rent toggle
          _ToggleBtn(
            label : 'Rent',
            paid  : m.rent,
            onTap : () {
              setState(() => m.rent = !m.rent);
              widget.onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// ── Toggle button ─────────────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final String       label;
  final bool         paid;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.paid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration : const Duration(milliseconds: 150),
        padding  : const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color       : paid
              ? _kGreenBg
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border      : Border.all(
            color: paid ? _kGreen : Colors.red.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children    : [
            Icon(
              paid
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              size : 18,
              color: paid ? _kGreen : Colors.red.shade400,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  fontSize  : 10,
                  fontWeight: FontWeight.w700,
                  color     : paid ? _kGreen : Colors.red.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Year nav button ───────────────────────────────────────────────────────────
class _YearNavBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;

  const _YearNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width : 36,
        height: 36,
        decoration: BoxDecoration(
          color       : _kBlueTint,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _kBlue, size: 20),
      ),
    );
  }
}

// ── Legend dot ────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color  color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width : 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: _kSubtext)),
      ],
    );
  }
}

// ── Status badge (used in confirm dialog) ─────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final bool   paid;
  const _StatusBadge({required this.label, required this.paid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding   : const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color       : paid ? _kGreenBg : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border      : Border.all(
            color: paid ? _kGreen : Colors.red.shade300),
      ),
      child: Text(
        '$label: ${paid ? "Paid" : "Not paid"}',
        style: TextStyle(
            fontSize  : 11,
            fontWeight: FontWeight.w700,
            color     : paid ? _kGreen : Colors.red.shade600),
      ),
    );
  }
}