import 'package:flutter/material.dart';

// ── Theme constants (shared with student page) ────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class SecurityLogPage extends StatelessWidget {
  const SecurityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ================= DUMMY APPROVED LOGS =================
    final List<_SecurityLog> logs = [
      _SecurityLog(
        name: "Anjali R",
        room: "1312",
        time: "05:30 AM",
        type: LogType.earlyExit,
      ),
      _SecurityLog(
        name: "Fathima N",
        room: "1315",
        time: "05:50 AM",
        type: LogType.earlyEntry,
      ),
      _SecurityLog(
        name: "Sherin Ibadh K",
        room: "1313",
        time: "09:45 PM",
        type: LogType.lateEntry,
      ),
      _SecurityLog(
        name: "Ayesha M",
        room: "1320",
        time: "10:10 PM",
        type: LogType.lateExit,
      ),
    ];

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
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Approved Security Log',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('Entry & exit movement records',
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

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width : 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color       : _kBlueTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.assignment_rounded,
                              color: _kBlue, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No log entries',
                            style: TextStyle(
                                color     : _kText,
                                fontSize  : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('No approved movements recorded yet',
                            style: TextStyle(
                                color  : _kSubtext,
                                fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return _SecurityLogCard(log: logs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Security log card ────────────────────────────────────────────────────────
class _SecurityLogCard extends StatelessWidget {
  final _SecurityLog log;

  const _SecurityLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(log.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border      : Border.all(color: _kBorder, width: 1.2),
        boxShadow   : const [
          BoxShadow(
              color     : Color(0x0C1565C0),
              blurRadius: 12,
              offset    : Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Colored top accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: style.color,
              borderRadius: const BorderRadius.only(
                topLeft : Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar icon
                Container(
                  width : 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color       : style.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(style.icon, color: style.color, size: 24),
                ),
                const SizedBox(width: 14),

                // Name, room, time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 14,
                              color     : _kText)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.door_front_door_rounded,
                              size: 12, color: _kSubtext),
                          const SizedBox(width: 4),
                          Text('Room ${log.room}',
                              style: const TextStyle(
                                  fontSize: 12, color: _kSubtext)),
                          const SizedBox(width: 10),
                          Icon(Icons.access_time_rounded,
                              size: 12, color: _kSubtext),
                          const SizedBox(width: 4),
                          Text(log.time,
                              style: TextStyle(
                                  fontSize  : 12,
                                  color     : style.color,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color : style.tint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: style.color.withOpacity(0.4)),
                  ),
                  child: Text(log.label,
                      style: TextStyle(
                          fontSize  : 10,
                          fontWeight: FontWeight.w800,
                          color     : style.color,
                          letterSpacing: 0.3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _LogStyle _resolveStyle(LogType type) {
    switch (type) {
      case LogType.earlyEntry:
        return _LogStyle(
            color: Colors.blue.shade600,
            tint : Colors.blue.shade50,
            icon : Icons.login_rounded);
      case LogType.earlyExit:
        return _LogStyle(
            color: Colors.blue.shade600,
            tint : Colors.blue.shade50,
            icon : Icons.logout_rounded);
      case LogType.lateEntry:
        return _LogStyle(
            color: Colors.red.shade600,
            tint : Colors.red.shade50,
            icon : Icons.login_rounded);
      case LogType.lateExit:
        return _LogStyle(
            color: Colors.red.shade600,
            tint : Colors.red.shade50,
            icon : Icons.logout_rounded);
    }
  }
}

class _LogStyle {
  final Color    color;
  final Color    tint;
  final IconData icon;

  const _LogStyle({
    required this.color,
    required this.tint,
    required this.icon,
  });
}

// ================= DATA MODEL =================

enum LogType {
  earlyEntry,
  earlyExit,
  lateEntry,
  lateExit,
}

class _SecurityLog {
  final String  name;
  final String  room;
  final String  time;
  final LogType type;

  const _SecurityLog({
    required this.name,
    required this.room,
    required this.time,
    required this.type,
  });

  String get label {
    switch (type) {
      case LogType.earlyEntry: return 'EARLY ENTRY';
      case LogType.earlyExit:  return 'EARLY EXIT';
      case LogType.lateEntry:  return 'LATE ENTRY';
      case LogType.lateExit:   return 'LATE EXIT';
    }
  }
}