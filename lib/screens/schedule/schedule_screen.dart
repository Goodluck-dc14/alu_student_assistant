import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _weekAnchor = _dateOnly(
    DateTime.now(),
  ); // any day in the selected week
  final List<_Session> _sessions = [];

  @override
  void initState() {
    super.initState();

    // Optional seed data
    final today = _dateOnly(DateTime.now());
    _sessions.addAll([
      _Session(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Mobile Dev Class',
        date: today,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 10, minute: 30),
        location: 'Room B2',
        type: _SessionType.classType,
        attendance: _AttendanceState.present,
      ),
      _Session(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Study Group',
        date: today.add(const Duration(days: 2)),
        start: const TimeOfDay(hour: 16, minute: 0),
        end: const TimeOfDay(hour: 17, minute: 0),
        location: 'Library',
        type: _SessionType.studyGroup,
        attendance: _AttendanceState.unmarked,
      ),
    ]);
  }

  DateTime get _weekStart => _startOfWeek(_weekAnchor);
  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  List<_Session> _sessionsForDay(DateTime d) {
    final day = _dateOnly(d);
    final items = _sessions.where((s) => _isSameDay(s.date, day)).toList();
    items.sort((a, b) => _compareTimes(a.start, b.start));
    return items;
  }

  Future<void> _openAddEditSheet({_Session? existing}) async {
    final result = await showModalBottomSheet<_Session>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionFormSheet(existing: existing),
    );

    if (result == null) return;

    setState(() {
      if (existing == null) {
        _sessions.add(result);
      } else {
        final idx = _sessions.indexWhere((s) => s.id == existing.id);
        if (idx != -1) _sessions[idx] = result;
      }
    });
  }

  void _deleteSession(_Session s) {
    setState(() => _sessions.removeWhere((x) => x.id == s.id));
  }

  void _setAttendance(_Session s, _AttendanceState state) {
    setState(() {
      final idx = _sessions.indexWhere((x) => x.id == s.id);
      if (idx == -1) return;
      _sessions[idx] = _sessions[idx].copyWith(attendance: state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgTop = const Color(0xFF071A2D);
    final bgBottom = const Color(0xFF0B2B4B);

    final headerRange =
        '${DateFormat('d MMM').format(_weekStart)} - ${DateFormat('d MMM').format(_weekStart.add(const Duration(days: 6)))}';

    return Scaffold(
      backgroundColor: bgTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Previous week',
            onPressed: () => setState(
              () => _weekAnchor = _weekAnchor.subtract(const Duration(days: 7)),
            ),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Center(
            child: Text(
              headerRange,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next week',
            onPressed: () => setState(
              () => _weekAnchor = _weekAnchor.add(const Duration(days: 7)),
            ),
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSheet(),
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _WeekStrip(
                days: _weekDays,
                anchor: _weekAnchor,
                onSelect: (d) => setState(() => _weekAnchor = _dateOnly(d)),
              ),
              const SizedBox(height: 12),
              for (final day in _weekDays) ...[
                _DayCard(
                  date: day,
                  sessions: _sessionsForDay(day),
                  onEdit: (s) => _openAddEditSheet(existing: s),
                  onDelete: _deleteSession,
                  onAttendanceChange: _setAttendance,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime anchor;
  final ValueChanged<DateTime> onSelect;

  const _WeekStrip({
    required this.days,
    required this.anchor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            for (final d in days) ...[
              Expanded(
                child: _DayPill(
                  date: d,
                  selected: _isSameDay(d, anchor),
                  onTap: () => onSelect(d),
                ),
              ),
              if (d != days.last) const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  const _DayPill({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEE').format(date);
    final dayNum = DateFormat('d').format(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final List<_Session> sessions;
  final ValueChanged<_Session> onEdit;
  final ValueChanged<_Session> onDelete;
  final void Function(_Session, _AttendanceState) onAttendanceChange;

  const _DayCard({
    required this.date,
    required this.sessions,
    required this.onEdit,
    required this.onDelete,
    required this.onAttendanceChange,
  });

  @override
  Widget build(BuildContext context) {
    final title = DateFormat('EEEE, d MMM').format(date);

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'No sessions.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < sessions.length; i++) ...[
                    _SessionTile(
                      session: sessions[i],
                      onEdit: () => onEdit(sessions[i]),
                      onDelete: () => onDelete(sessions[i]),
                      onAttendanceChange: (a) =>
                          onAttendanceChange(sessions[i], a),
                    ),
                    if (i != sessions.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final _Session session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<_AttendanceState> onAttendanceChange;

  const _SessionTile({
    required this.session,
    required this.onEdit,
    required this.onDelete,
    required this.onAttendanceChange,
  });

  @override
  Widget build(BuildContext context) {
    final time = '${_fmtTime(session.start)} - ${_fmtTime(session.end)}';
    final subtitle = [
      session.type.label,
      time,
      if (session.location.trim().isNotEmpty) session.location,
    ].join(' • ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        session.title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      trailing: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _AttendanceToggle(
            value: session.attendance,
            onChanged: onAttendanceChange,
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.black54),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet form to add/edit a session.
class _SessionFormSheet extends StatefulWidget {
  final _Session? existing;

  const _SessionFormSheet({required this.existing});

  @override
  State<_SessionFormSheet> createState() => _SessionFormSheetState();
}

class _SessionFormSheetState extends State<_SessionFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;

  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  _SessionType _type = _SessionType.classType;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _locationCtrl = TextEditingController(
      text: widget.existing?.location ?? '',
    );
    _date = widget.existing?.date;
    _start = widget.existing?.start;
    _end = widget.existing?.end;
    _type = widget.existing?.type ?? _SessionType.classType;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _date ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => _date = _dateOnly(picked));
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;
    setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _end ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null) return;
    setState(() => _end = picked);
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_date == null || _start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date, start time, and end time.'),
        ),
      );
      return;
    }

    final startM = _start!.hour * 60 + _start!.minute;
    final endM = _end!.hour * 60 + _end!.minute;
    if (endM <= startM) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    final isEdit = widget.existing != null;

    final session = _Session(
      id: isEdit
          ? widget.existing!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      date: _date!,
      start: _start!,
      end: _end!,
      location: _locationCtrl.text.trim(),
      type: _type,
      attendance: widget.existing?.attendance ?? _AttendanceState.unmarked,
    );

    Navigator.pop(context, session);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B2B4B),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      widget.existing == null ? 'New Session' : 'Edit Session',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('Session title *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required.'
                      : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _date == null
                              ? 'Pick date *'
                              : DateFormat('EEE, d MMM yyyy').format(_date!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickStart,
                        icon: const Icon(Icons.schedule),
                        label: Text(
                          _start == null
                              ? 'Start time *'
                              : _start!.format(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickEnd,
                        icon: const Icon(Icons.schedule),
                        label: Text(
                          _end == null ? 'End time *' : _end!.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('Location (optional)'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<_SessionType>(
                  value: _type,
                  decoration: _fieldDecoration('Session type'),
                  dropdownColor: const Color(0xFF0B2B4B),
                  items: _SessionType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _type = v ?? _SessionType.classType),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      widget.existing == null ? 'Create' : 'Save Changes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
      ),
    );
  }
}

class _AttendanceToggle extends StatelessWidget {
  final _AttendanceState value;
  final ValueChanged<_AttendanceState> onChanged;

  const _AttendanceToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AttendanceState>(
      tooltip: 'Attendance',
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _AttendanceState.unmarked,
          child: Text('— Unmarked'),
        ),
        PopupMenuItem(value: _AttendanceState.present, child: Text('Present')),
        PopupMenuItem(value: _AttendanceState.absent, child: Text('Absent')),
      ],
      child: _AttendancePill(value: value),
    );
  }
}

class _AttendancePill extends StatelessWidget {
  final _AttendanceState value;
  const _AttendancePill({required this.value});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    switch (value) {
      case _AttendanceState.present:
        label = 'Present';
        bg = const Color(0xFFE7F6EA);
        fg = const Color(0xFF1B7A2E);
        break;
      case _AttendanceState.absent:
        label = 'Absent';
        bg = const Color(0xFFFCE8E8);
        fg = const Color(0xFFB71C1C);
        break;
      case _AttendanceState.unmarked:
        label = '—';
        bg = const Color(0xFFF2F2F2);
        fg = Colors.black54;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

enum _SessionType { classType, masterySession, studyGroup, pslMeeting }

extension on _SessionType {
  String get label {
    switch (this) {
      case _SessionType.classType:
        return 'Class';
      case _SessionType.masterySession:
        return 'Mastery Session';
      case _SessionType.studyGroup:
        return 'Study Group';
      case _SessionType.pslMeeting:
        return 'PSL Meeting';
    }
  }
}

enum _AttendanceState { unmarked, present, absent }

class _Session {
  final String id;
  final String title;
  final DateTime date; // date-only
  final TimeOfDay start;
  final TimeOfDay end;
  final String location;
  final _SessionType type;
  final _AttendanceState attendance;

  const _Session({
    required this.id,
    required this.title,
    required this.date,
    required this.start,
    required this.end,
    required this.location,
    required this.type,
    required this.attendance,
  });

  _Session copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? start,
    TimeOfDay? end,
    String? location,
    _SessionType? type,
    _AttendanceState? attendance,
  }) {
    return _Session(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      location: location ?? this.location,
      type: type ?? this.type,
      attendance: attendance ?? this.attendance,
    );
  }
}

// ---------- helpers (pure functions) ----------

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _startOfWeek(DateTime d) {
  final date = _dateOnly(d);
  // Monday as start (DateTime.monday = 1)
  final diff = date.weekday - DateTime.monday;
  return date.subtract(Duration(days: diff));
}

int _compareTimes(TimeOfDay a, TimeOfDay b) {
  final am = a.hour * 60 + a.minute;
  final bm = b.hour * 60 + b.minute;
  return am.compareTo(bm);
}

String _fmtTime(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
