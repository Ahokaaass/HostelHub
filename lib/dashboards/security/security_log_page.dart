// ============================================================
// FILE: lib/dashboards/security/security_log_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../model/gate_request_model.dart';

const _kBlue = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);

class SecurityLogPage extends StatefulWidget {
  const SecurityLogPage({super.key});

  @override
  State<SecurityLogPage> createState() => _SecurityLogPageState();
}

class _SecurityLogPageState extends State<SecurityLogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String raw) {
    try {
      final p = raw.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  bool _isToday(GateRequest r) {
    final d = _parseDate(r.date);
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isTodayOrPast(GateRequest r) {
    final d = _parseDate(r.date);
    if (d == null) return true;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return !d.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Security Log"),
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Today"),
            Tab(text: "Previous"),
          ],
        ),
      ),
      body: StreamBuilder<List<GateRequest>>(
        stream: GateRequestService.streamForSecurity(),
        builder: (context, pendSnap) {
          return StreamBuilder<List<GateRequest>>(
            stream: GateRequestService.streamSecurityDone(),
            builder: (context, doneSnap) {
              if (pendSnap.connectionState == ConnectionState.waiting ||
                  doneSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _kBlue),
                );
              }

              final pending = (pendSnap.data ?? [])
                  .where(_isTodayOrPast)
                  .toList();
              final done = doneSnap.data ?? [];

              final todayList = [
                ...pending.where(_isToday),
                ...done.where(_isToday),
              ];
              final prevList = done.where((r) => !_isToday(r)).toList();

              return TabBarView(
                controller: _tab,
                children: [
                  _buildList(context, todayList, "No entries for today"),
                  _buildList(context, prevList, "No previous entries"),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext ctx, List<GateRequest> list, String empty) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              empty,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: list.length,
      itemBuilder: (_, i) => _tile(ctx, list[i]),
    );
  }

  Widget _tile(BuildContext context, GateRequest r) {
    final isDone = r.status == GateStatus.securityDone;
    final logType = r.logType;
    final isEarly =
        logType == LogType.earlyEntry || logType == LogType.earlyExit;
    final Color color = isEarly ? _kBlue : const Color(0xFFDC3545);
    final IconData icon =
        (logType == LogType.earlyEntry || logType == LogType.lateEntry)
        ? Icons.login
        : Icons.logout;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Room ${r.room}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: color),
                      const SizedBox(width: 4),
                      Text(
                        r.time,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          r.type,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            if (!isDone)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _allow(context, r),
                child: const Text(
                  "Allow",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  "Allowed",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _allow(BuildContext context, GateRequest r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_open, color: _kBlueLight),
            SizedBox(width: 8),
            Text(
              "Allow Exit/Entry?",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                "Room ${r.room}  ·  ${r.type}",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "Requested: ${r.time}",
                style: const TextStyle(color: _kBlueLight, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Allow",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;
    try {
      await GateRequestService.updateStatus(r.id, {
        'status': GateStatus.securityDone,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}