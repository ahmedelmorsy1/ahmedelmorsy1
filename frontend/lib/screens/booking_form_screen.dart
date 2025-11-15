import 'package:flutter/material.dart';

import '../models/pitch.dart';
import '../services/api_client.dart';

class BookingFormSheet extends StatefulWidget {
  const BookingFormSheet({
    super.key,
    required this.apiClient,
    required this.pitch,
  });

  final ApiClient apiClient;
  final Pitch pitch;

  @override
  State<BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<BookingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime? _selectedDate = DateTime.now();
  String? _selectedSlot;
  Set<String> _unavailableSlots = const <String>{};
  bool _submitting = false;
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    if (widget.pitch.slots.isNotEmpty) {
      _selectedSlot = widget.pitch.slots.first;
    }
    _refreshUnavailableSlots();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _refreshUnavailableSlots() async {
    final date = _selectedDate;
    if (date == null) {
      return;
    }

    setState(() {
      _loadingSlots = true;
    });

    try {
      final bookings = await widget.apiClient.fetchBookings(
        pitchId: widget.pitch.id,
        date: date,
      );
      final occupied = bookings.map((booking) => booking.slot).toSet();
      setState(() {
        _unavailableSlots = occupied;
        if (_selectedSlot != null && occupied.contains(_selectedSlot)) {
          _selectedSlot = widget.pitch.slots
              .firstWhere(
                (slot) => !occupied.contains(slot),
                orElse: () => widget.pitch.slots.isEmpty ? '' : widget.pitch.slots.first,
              )
              .takeIf((value) => value.isNotEmpty);
        }
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحميل المواعيد المحجوزة: ${error.message}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingSlots = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: padding,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حجز ملعب ${widget.pitch.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم العميل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال اسم العميل';
                    }
                    if (value.trim().length < 3) {
                      return 'الاسم يجب أن يكون على الأقل 3 أحرف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    if (trimmed.length < 10) {
                      return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _submitting ? null : _pickDate,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'اختر التاريخ',
                        ),
                      ),
                    ),
                    if (_loadingSlots) ...[
                      const SizedBox(width: 12),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.pitch.slots.isEmpty)
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'المواعيد المتاحة',
                      border: OutlineInputBorder(),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('لا توجد مواعيد محددة لهذا الملعب حاليًا.'),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: widget.pitch.slots.contains(_selectedSlot)
                        ? _selectedSlot
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'اختر الميعاد',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء اختيار ميعاد مناسب';
                      }
                      if (_unavailableSlots.contains(value)) {
                        return 'هذا الميعاد تم حجزه بالفعل';
                      }
                      return null;
                    },
                    items: widget.pitch.slots
                        .map(
                          (slot) => DropdownMenuItem(
                            enabled: !_unavailableSlots.contains(slot),
                            value: slot,
                            child: Row(
                              children: [
                                Text(slot),
                                if (_unavailableSlots.contains(slot)) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.lock_clock, size: 16, color: Colors.redAccent),
                                ],
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _submitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedSlot = value;
                            });
                          },
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  onPressed: _submitting ? null : _submit,
                  label: const Text('تأكيد الحجز'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () {
                          Navigator.of(context).pop(false);
                        },
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null && _selectedDate!.isAfter(now)
          ? _selectedDate!
          : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      await _refreshUnavailableSlots();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (widget.pitch.slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مواعيد متاحة لهذا الملعب حالياً.')),
      );
      return;
    }
    if (_selectedDate == null || _selectedSlot == null || _selectedSlot!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ والميعاد.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await widget.apiClient.createBooking(
        pitchId: widget.pitch.id,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        date: _selectedDate!,
        slot: _selectedSlot!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إنشاء الحجز: ${error.message}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final weekdayNames = <int, String>{
      DateTime.saturday: 'السبت',
      DateTime.sunday: 'الأحد',
      DateTime.monday: 'الاثنين',
      DateTime.tuesday: 'الثلاثاء',
      DateTime.wednesday: 'الأربعاء',
      DateTime.thursday: 'الخميس',
      DateTime.friday: 'الجمعة',
    };

    final monthNames = <int, String>{
      1: 'يناير',
      2: 'فبراير',
      3: 'مارس',
      4: 'أبريل',
      5: 'مايو',
      6: 'يونيو',
      7: 'يوليو',
      8: 'أغسطس',
      9: 'سبتمبر',
      10: 'أكتوبر',
      11: 'نوفمبر',
      12: 'ديسمبر',
    };

    final weekday = weekdayNames[date.weekday] ?? '';
    final month = monthNames[date.month] ?? '';
    return '$weekday ${date.day} $month ${date.year}';
  }
}

extension TakeIfExtension<T> on T {
  T? takeIf(bool Function(T value) predicate) {
    if (predicate(this)) {
      return this;
    }
    return null;
  }
}
