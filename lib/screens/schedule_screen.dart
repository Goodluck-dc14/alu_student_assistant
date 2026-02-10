import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/academic_session.dart';
import '../providers/session_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _anchorDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final weekSessions = provider.weeklySessions(_anchorDate);

    final weekStart = _startOfWeek(_anchorDate);
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSessionForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _anchorDate = _anchorDate.subtract(const Duration(days: 7));
                  }),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _anchorDate = _anchorDate.add(const Duration(days: 7));
                  }),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: weekSessions.isEmpty
                ? const Center(child: Text('No sessions this week'))
                : ListView.builder(
                    itemCount: weekSessions.length,
                    itemBuilder: (context, index) {
                      final s = weekSessions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final updated =
                                            await showModalBottomSheet<AcademicSession>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (_) => _SessionForm(existing: s),
                                        );
                                        if (updated != null) {
                                          provider.updateSession(s.id, updated);
                                        }
                                      } else if (value == 'delete') {
                                        provider.removeSession(s.id);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(DateFormat('EEE, dd MMM yyyy').format(s.date)),
                              Text(
                                '${DateFormat('HH:mm').format(s.startDateTime)} - '
                                '${DateFormat('HH:mm').format(s.endDateTime)}',
                              ),
                              Text(AcademicSession.typeLabel(s.type)),
                              if ((s.location ?? '').trim().isNotEmpty)
                                Text('Location: ${s.location}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Attendance: '),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Present'),
                                    selected:
                                        s.attendance == AttendanceStatus.present,
                                    onSelected: (_) => provider.setAttendance(
                                      s.id,
                                      AttendanceStatus.present,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Absent'),
                                    selected:
                                        s.attendance == AttendanceStatus.absent,
                                    onSelected: (_) => provider.setAttendance(
                                      s.id,
                                      AttendanceStatus.absent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  DateTime _startOfWeek(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final diff = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: diff));
  }

  Future<void> _openSessionForm(BuildContext context) async {
    final provider = context.read<SessionProvider>();

    final created = await showModalBottomSheet<AcademicSession>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SessionForm(),
    );

    if (!mounted || created == null) return;
    provider.addSession(created);
  }
}

class _SessionForm extends StatefulWidget {
  final AcademicSession? existing;
  const _SessionForm({this.existing});

  @override
  State<_SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<_SessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _uuid = const Uuid();

  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  SessionType _type = SessionType.classType;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _locationController.text = e.location ?? '';
      _date = DateTime(e.date.year, e.date.month, e.date.day);
      _start = TimeOfDay.fromDateTime(e.startDateTime);
      _end = TimeOfDay.fromDateTime(e.endDateTime);
      _type = e.type;
    } else {
      final now = DateTime.now();
      _date = DateTime(now.year, now.month, now.day);
      _start = const TimeOfDay(hour: 9, minute: 0);
      _end = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  DateTime _merge(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? 'Add Session' : 'Edit Session',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Session title *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat('dd MMM yyyy').format(_date)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _start,
                        );
                        if (picked != null) setState(() => _start = picked);
                      },
                      child: Text('Start: ${_start.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _end,
                        );
                        if (picked != null) setState(() => _end = picked);
                      },
                      child: Text('End: ${_end.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<SessionType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Session type',
                  border: OutlineInputBorder(),
                ),
                items: SessionType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(AcademicSession.typeLabel(t)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    final start = _merge(_date, _start);
                    final end = _merge(_date, _end);

                    if (!end.isAfter(start)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('End time must be after start time'),
                        ),
                      );
                      return;
                    }

                    final existing = widget.existing;
                    final session = AcademicSession(
                      id: existing?.id ?? _uuid.v4(),
                      title: _titleController.text.trim(),
                      date: DateTime(_date.year, _date.month, _date.day),
                      startDateTime: start,
                      endDateTime: end,
                      location: _locationController.text.trim().isEmpty
                          ? null
                          : _locationController.text.trim(),
                      type: _type,
                      attendance: existing?.attendance ?? AttendanceStatus.unset,
                    );

                    Navigator.of(context).pop(session);
                  },
                  child: Text(
                    widget.existing == null ? 'Create Session' : 'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

