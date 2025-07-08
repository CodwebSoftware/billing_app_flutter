import 'package:billing_app_flutter/db/controllers/appointments_controller.dart';
import 'package:billing_app_flutter/db/controllers/customer_controller.dart';
import 'package:billing_app_flutter/db/controllers/employee_controller.dart';
import 'package:billing_app_flutter/db/controllers/sale_entry_controller.dart';
import 'package:billing_app_flutter/db/controllers/service_controller.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_services_entity.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/sale_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:billing_app_flutter/db/models/appointment_entity.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'dart:async';

enum DateStatus { available, partiallyBooked, fullyBooked }

enum AppointmentType { regular, walkIn, online }

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  _AppointmentBookingScreenState createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final AppointmentsController _appointmentsController =
      Get.find<AppointmentsController>();
  final EmployeeController _employeeController = Get.find<EmployeeController>();
  final CustomerController _customerController = Get.find<CustomerController>();
  final ServiceController _serviceController = Get.find<ServiceController>();

  Map<TimeOfDay, List<EmployeeEntity>> _slotWorkerAssignments = {};
  CustomerEntity? _selectedCustomer;
  List<EmployeeEntity> _selectedEmployees = [];
  List<ServiceEntity> _selectedServices = [];
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<TimeOfDay> _selectedTimes = [];
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _waitlistNotesController =
      TextEditingController();
  final TimeOfDay _openTime = const TimeOfDay(hour: 10, minute: 0);
  final TimeOfDay _closeTime = const TimeOfDay(hour: 17, minute: 0);
  final int _appointmentDuration = 30;
  AppointmentType _appointmentType = AppointmentType.regular;
  bool _sendReminder = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _slotWorkerAssignments = {};
    _selectedDay = _focusedDay;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait(
        [
              _customerController.getCustomersByNameOrMobile(""),
              _employeeController.getAll(),
              _serviceController.loadServices(),
              _appointmentsController.getAppointmentsByDate(_selectedDay!),
            ]
            as Iterable<Future>,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  DateStatus _getDateStatus(DateTime date) {
    final slots = _generateTimeSlots(date);
    if (slots.isEmpty) return DateStatus.fullyBooked;

    final bookedCount = _getBookedSlotsForDay(date).length;
    if (bookedCount == 0) return DateStatus.available;

    final bookingRatio = bookedCount / slots.length;
    return bookingRatio > 0.75
        ? DateStatus.fullyBooked
        : DateStatus.partiallyBooked;
  }

  List<DateTime> _getBookedSlotsForDay(DateTime day) {
    return _appointmentsController
        .getAppointmentsByDate(day)
        .map((appoint) => appoint.dateTime!)
        .toList();
  }

  List<DateTime> _generateTimeSlots(DateTime day) {
    final List<DateTime> slots = [];
    final now = DateTime.now();

    if (day.isBefore(DateTime(now.year, now.month, now.day))) {
      return slots;
    }

    DateTime currentSlot = DateTime(
      day.year,
      day.month,
      day.day,
      _openTime.hour,
      _openTime.minute,
    );
    final DateTime endTime = DateTime(
      day.year,
      day.month,
      day.day,
      _closeTime.hour,
      _closeTime.minute,
    );

    while (currentSlot.isBefore(endTime)) {
      if (!isSameDay(day, now) || currentSlot.isAfter(now)) {
        slots.add(currentSlot);
      }
      currentSlot = currentSlot.add(Duration(minutes: _appointmentDuration));
    }
    return slots;
  }

  Future<void> _bookAppointment() async {
    const int maxCapacity = 5; // Maximum customers per time slot

    if (_selectedCustomer == null ||
        _selectedTimes.isEmpty ||
        _slotWorkerAssignments.isEmpty ||
        _selectedServices.isEmpty ||
        _notesController.text.isEmpty ||
        _slotWorkerAssignments.values.any((workers) => workers.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required fields and assign stylists to each slot',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Track saved appointments to avoid duplicates
      final Set<String> savedAppointments = {};

      for (final time in _selectedTimes) {
        final baseDateTime = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
          time.hour,
          time.minute,
        );

        // Get workers assigned to this slot
        final assignedWorkers = _slotWorkerAssignments[time]!;
        if (assignedWorkers.isEmpty) continue; // Skip if no workers assigned

        // Create a unique key for this appointment
        final appointmentKey =
            '${baseDateTime.toIso8601String()}-${_selectedCustomer!.id}-${_selectedServices.map((s) => s.id).join('-')}';

        if (savedAppointments.contains(appointmentKey)) continue;

        // Check total appointments for this slot (capacity <= 5)
        final slotAppointments =
            _appointmentsController
                .getAppointmentsByDate(baseDateTime)
                .where((appt) => appt.dateTime!.isAtSameMomentAs(baseDateTime))
                .toList();

        if (slotAppointments.length >= maxCapacity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Slot at ${DateFormat.jm().format(baseDateTime)} is fully booked (capacity: $maxCapacity)',
              ),
            ),
          );
          return;
        }

        // Check if any assigned worker is already booked for this slot
        for (final employee in assignedWorkers) {
          final isBooked = slotAppointments.any(
            (appt) => appt.employees.any((e) => e.id == employee.id),
          );

          if (isBooked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Slot at ${DateFormat.jm().format(baseDateTime)} is already booked for ${employee.name}',
                ),
              ),
            );
            return;
          }
        }

        // Create a new appointment for this single slot
        final appointment = AppointmentEntity();
        appointment.client.target = _selectedCustomer;
        appointment.dateTime = baseDateTime;
        appointment.notes = _notesController.text;
        appointment.type = _appointmentType.toString().split('.').last;
        appointment.sendReminder = _sendReminder;
        appointment.services.addAll(_selectedServices);
        appointment.employees.addAll(assignedWorkers);

        await _appointmentsController.saveAppointment(appointment);
        savedAppointments.add(appointmentKey);
      }

      // Refresh appointments for the selected customer
      await _appointmentsController.getAppointmentsByCustomer(
        _selectedCustomer!.id!,
      );

      // Clear all selected values and force UI refresh
      setState(() {
        _selectedCustomer = null;
        _selectedTimes.clear();
        _selectedEmployees.clear();
        _slotWorkerAssignments.clear();
        _selectedServices.clear();
        _notesController.clear();
        _appointmentType = AppointmentType.regular;
        _sendReminder = true;
        _focusedDay = DateTime.now();
        _selectedDay = _focusedDay;
      });

      // Notify controllers
      _customerController.update();
      _employeeController.update();
      _serviceController.update();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointments booked successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<EmployeeEntity> _getAvailableEmployees(DateTime slot) {
    if (_selectedDay == null) {
      return _employeeController.getAllEmployeeByRole("Worker");
    }

    final bookedEmployeeIds =
        _appointmentsController
            .getAppointmentsByDate(slot)
            .where((appt) => appt.dateTime!.isAtSameMomentAs(slot))
            .expand((appt) => appt.employees.map((e) => e.id))
            .toSet();

    return _employeeController
        .getAllEmployeeByRole("Worker")
        .where((emp) => !bookedEmployeeIds.contains(emp.id))
        .toList();
  }

  Future<void> _addToWaitlist() async {
    if (_selectedCustomer == null ||
        _selectedDay == null ||
        _waitlistNotesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Customer, Date, and add Waitlist Notes'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _appointmentsController.addToWaitlist(
        _selectedCustomer!,
        _selectedDay!,
        _waitlistNotesController.text,
        _selectedServices,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to waitlist!')));

      setState(() {
        _waitlistNotesController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to waitlist: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment(AppointmentEntity appointment) async {
    setState(() => _isLoading = true);
    try {
      appointment.status = "Cancelled";
      _appointmentsController.cancelAppointment(appointment);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel appointment: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getDateColor(DateTime date) {
    switch (_getDateStatus(date)) {
      case DateStatus.available:
        return Colors.green.shade100;
      case DateStatus.partiallyBooked:
        return Colors.yellow.shade100;
      case DateStatus.fullyBooked:
        return Colors.red.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final bookedSlots = _getBookedSlotsForDay(_selectedDay!);
    final availableSlots = _generateTimeSlots(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child:
                    isDesktop
                        ? _buildDesktopLayout(availableSlots, bookedSlots)
                        : _buildMobileLayout(availableSlots, bookedSlots),
              ),
    );
  }

  Widget _buildDesktopLayout(
    List<DateTime> availableSlots,
    List<DateTime> bookedSlots,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Booking Form
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildBookingForm(availableSlots, bookedSlots),
            ),
          ),
        ),
        // Right side - Appointments List
        Container(
          width: 400,
          padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildAppointmentsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    List<DateTime> availableSlots,
    List<DateTime> bookedSlots,
  ) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _buildBookingForm(availableSlots, bookedSlots),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildAppointmentsList(),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }

  Widget _buildBookingForm(
    List<DateTime> availableSlots,
    List<DateTime> bookedSlots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDateSelector(),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 24),
        _buildCustomerSelector(),
        const SizedBox(height: 16),
        _buildAppointmentTypeSelector(),
        const SizedBox(height: 16),
        _buildTimeSlotSelector(availableSlots, bookedSlots),
        const SizedBox(height: 16),
        _buildEmployeeSelector(),
        const SizedBox(height: 16),
        _buildServiceSelector(),
        const SizedBox(height: 16),
        _buildNotesField(),
        const SizedBox(height: 16),
        _buildReminderToggle(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Date',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedTimes.clear();
                  _slotWorkerAssignments.clear();
                  _selectedEmployees.clear();
                });
              },
              onFormatChanged:
                  (format) => setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              eventLoader: _appointmentsController.getAppointmentsByDate,
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getDateColor(_focusedDay),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getDateColor(_focusedDay),
                ),
                outsideDecoration: const BoxDecoration(shape: BoxShape.circle),
              ),
              headerStyle: HeaderStyle(
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                titleCentered: true,
                formatButtonVisible: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                weekendStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(Colors.green.shade100, 'Available'),
        _buildLegendItem(Colors.yellow.shade100, 'Limited'),
        _buildLegendItem(Colors.red.shade100, 'Booked'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCustomerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Customer',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              _selectedCustomer?.name ?? 'Select Customer',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    _selectedCustomer == null
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: _showCustomerDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Appointment Type',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        DropdownButtonFormField<AppointmentType>(
          value: _appointmentType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          items:
              AppointmentType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.toString().split('.').last.capitalizeFirst!,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              _appointmentType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector(
    List<DateTime> availableSlots,
    List<DateTime> bookedSlots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Available Time Slots',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        availableSlots.isEmpty
            ? _buildEmptyState(
              icon: Icons.access_time,
              message: 'No available slots for selected date',
            )
            : Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  availableSlots.map((slot) {
                    final time = TimeOfDay.fromDateTime(slot);
                    final isSelected = _selectedTimes.contains(time);
                    final slotAppointments =
                        _appointmentsController
                            .getAppointmentsByDate(slot)
                            .where(
                              (appt) => appt.dateTime!.isAtSameMomentAs(slot),
                            )
                            .toList();
                    final isFullyBooked = slotAppointments.length >= 5;
                    final capacityText = ' (${slotAppointments.length}/5)';

                    return FilterChip(
                      label: Text(
                        '${DateFormat.jm().format(slot)}$capacityText',
                        style: TextStyle(
                          color:
                              isFullyBooked
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer
                                  : isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      onSelected:
                          isFullyBooked
                              ? null
                              : (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTimes.add(time);
                                  } else {
                                    _selectedTimes.remove(time);
                                    _slotWorkerAssignments.remove(time);
                                    _selectedEmployees =
                                        _slotWorkerAssignments.values
                                            .expand((workers) => workers)
                                            .toSet()
                                            .toList();
                                  }
                                });
                              },
                      backgroundColor:
                          isFullyBooked
                              ? Theme.of(context).colorScheme.errorContainer
                              : _getDateColor(_selectedDay!),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      disabledColor:
                          Theme.of(context).colorScheme.errorContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      showCheckmark: false,
                      avatar:
                          isSelected
                              ? Icon(
                                Icons.check,
                                size: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                              : null,
                    );
                  }).toList(),
            ),
      ],
    );
  }

  Widget _buildEmployeeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Assigned Stylists',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (_slotWorkerAssignments.isEmpty)
          _buildEmptyState(
            icon: Icons.people_outline,
            message: 'No stylists assigned',
            action:
                _selectedTimes.isNotEmpty && _selectedDay != null
                    ? FilledButton.tonal(
                      onPressed: () => _showEmployeeDialog(context),
                      child: const Text('Assign Stylists'),
                    )
                    : null,
          )
        else
          Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _slotWorkerAssignments.entries.map((entry) {
                      final time = entry.key;
                      final workers = entry.value;
                      final slot = DateTime(
                        _selectedDay?.year ?? DateTime.now().year,
                        _selectedDay?.month ?? DateTime.now().month,
                        _selectedDay?.day ?? DateTime.now().day,
                        time.hour,
                        time.minute,
                      );
                      final workerNames = workers
                          .map((e) => '${e.name} (${e.specialty})')
                          .join(', ');
                      return InputChip(
                        label: Text(
                          '${DateFormat.jm().format(slot)}: $workerNames',
                          style: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        deleteIcon: Icon(
                          Icons.close,
                          size: 18,
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                        ),
                        onDeleted: () {
                          setState(() {
                            _slotWorkerAssignments.remove(time);
                            _selectedEmployees =
                                _slotWorkerAssignments.values
                                    .expand((workers) => workers)
                                    .toSet()
                                    .toList();
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _showEmployeeDialog(context),
                child: const Text('Edit Stylist Assignments'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildServiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Services',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (_serviceController.services.isEmpty)
          _buildEmptyState(
            icon: Icons.spa_outlined,
            message: 'No services available',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _serviceController.services.map((service) {
                  final isSelected = _selectedServices.contains(service);
                  return FilterChip(
                    label: Text(service.name!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedServices.add(service);
                        } else {
                          _selectedServices.remove(service);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    showCheckmark: false,
                    avatar:
                        isSelected
                            ? Icon(
                              Icons.check,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                            : null,
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Appointment Notes',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notes',
            hintText: 'Enter any additional information',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          maxLines: 3,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _buildReminderToggle() {
    return SwitchListTile(
      title: const Text('Send Appointment Reminder'),
      value: _sendReminder,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: (value) {
        setState(() {
          _sendReminder = value;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    final isValid =
        _selectedDay != null &&
        _selectedTimes.isNotEmpty &&
        _selectedCustomer != null &&
        _slotWorkerAssignments.isNotEmpty &&
        _selectedServices.isNotEmpty &&
        _notesController.text.isNotEmpty &&
        !_slotWorkerAssignments.values.any((workers) => workers.isEmpty);

    return Column(
      children: [
        FilledButton(
          onPressed: isValid ? _bookAppointment : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Book Appointment'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _addToWaitlist,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Add to Waitlist'),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildGroupedAppointments()),
        ],
      ),
    );
  }

  Widget _buildGroupedAppointments() {
    // Get appointments for the selected day
    final appointments = _appointmentsController.getAppointmentsByDate(
      _selectedDay!,
    );

    // Group appointments by customer
    final Map<String, List<AppointmentEntity>> groupedAppointments = {};
    for (var appt in appointments) {
      final customer = appt.client.target;
      if (customer == null) continue;
      final customerId = customer.id.toString();
      groupedAppointments.putIfAbsent(customerId, () => []).add(appt);
    }

    // Sort appointments within each group by dateTime and ID
    groupedAppointments.forEach((_, appts) {
      appts.sort((a, b) {
        final timeCompare = a.dateTime!.compareTo(b.dateTime!);
        return timeCompare != 0 ? timeCompare : a.id.compareTo(b.id);
      });
    });

    // Build UI for grouped appointments
    final List<Widget> groupWidgets = [];
    final formatter = DateFormat.jm();
    for (var entry in groupedAppointments.entries) {
      final customerId = entry.key;
      final appts = entry.value;
      final customer = appts.first.client.target!;
      final allCompleted = appts.every((appt) => appt.status == "Completed");
      final allCanceled = appts.every((appt) => appt.status == "Canceled");
      final anyScheduled = appts.any((appt) => appt.status == "Scheduled");

      groupWidgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color:
              allCompleted
                  ? Theme.of(context).colorScheme.primaryContainer
                  : allCanceled
                  ? Theme.of(context).colorScheme.errorContainer
                  : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Icon(
                  allCompleted
                      ? Icons.check_circle
                      : allCanceled
                      ? Icons.cancel
                      : Icons.event,
                  color:
                      allCompleted
                          ? Theme.of(context).colorScheme.primary
                          : allCanceled
                          ? Theme.of(context).colorScheme.error
                          : null,
                ),
                title: Text(
                  customer.name!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: allCanceled ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${appts.length} appointment(s)'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'complete') {
                      _completeAppointment(appts);
                    } else if (value == 'cancel') {
                      _bulkCancelAppointments(appts);
                    } else if (value == 'reschedule') {
                      _bulkRescheduleAppointments(appts);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'complete',
                          child: Text('Mark Complete'),
                        ),
                        const PopupMenuItem(
                          value: 'reschedule',
                          child: Text('Reschedule'),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('Cancel'),
                        ),
                      ],
                ),
              ),
              const Divider(height: 1),
              ...appts.map((appt) {
                final slotTime = formatter.format(appt.dateTime!);
                final serviceNames = appt.services
                    .map((service) => service.name)
                    .toSet()
                    .join(', ');
                final employeeNames = appt.employees
                    .map((emp) => '${emp.name} (${emp.specialty})')
                    .toSet()
                    .join(', ');
                final apptType = appt.type;
                final apptStatus = appt.status ?? "Scheduled";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    'Slot: $slotTime',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration:
                          apptStatus == "Canceled"
                              ? TextDecoration.lineThrough
                              : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services: ${serviceNames.isEmpty ? "N/A" : serviceNames}',
                      ),
                      Text(
                        'Stylists: ${employeeNames.isEmpty ? "N/A" : employeeNames}',
                      ),
                      Text('Type: $apptType'),
                      Text('Status: $apptStatus'),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    }

    return ListView(
      children:
          groupWidgets.isEmpty
              ? [
                _buildEmptyState(
                  icon: Icons.calendar_today,
                  message: 'No appointments for this day',
                ),
              ]
              : groupWidgets,
    );
  }

  Future<void> _bulkCancelAppointments(
    List<AppointmentEntity> appointments,
  ) async {
    setState(() => _isLoading = true);
    try {
      for (var appt in appointments) {
        if (appt.status == "Scheduled") {
          await _cancelAppointment(appt);
        }
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel appointments: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bulkRescheduleAppointments(
    List<AppointmentEntity> appointments,
  ) async {
    if (appointments.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final firstAppt = appointments.first;

      for (var appt in appointments) {
        appt.status == "Scheduled";
        await _cancelAppointment(appt);
      }

      // Initialize rescheduling state
      setState(() {
        _selectedCustomer = firstAppt.client.target;
        _selectedServices =
            appointments.expand((appt) => appt.services).toSet().toList();
        _notesController.text = firstAppt.notes ?? '';
        _appointmentType = AppointmentType.values.firstWhere(
          (type) => type.toString().split('.').last == firstAppt.type,
          orElse: () => AppointmentType.regular,
        );
        _sendReminder = firstAppt.sendReminder ?? true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reschedule appointments: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeAppointment(
    List<AppointmentEntity> appointments,
  ) async {
    if (appointments.isEmpty) return;
    final customer = appointments.first.client.target;
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid customer for appointment')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Clear existing invoice data
      final invoiceController = Get.find<SaleEntryController>();
      invoiceController.invoiceServiceList.clear();
      invoiceController.invoiceItemList.clear();

      // Populate services from all appointments
      for (var appt in appointments) {
        for (var service in appt.services) {
          final invoiceService = SaleEntryServicesEntity(

          );
          invoiceService.service.target!.id = service.id;
          invoiceService.price= service.price;
          invoiceService.quantity= 1;
          invoiceController.addInvoiceService(invoiceService);
        }
      }

      // Create new invoice
      final invoice = SaleEntryEntity();
      invoice.date = DateTime.now();
      invoice.invoiceNumber =
      'INV-${customer.id}-${invoiceController
    .count() + 1}-${DateTime.now().millisecondsSinceEpoch}';
      invoice.totalBillAmount = appointments.fold(
        0.0,
        (sum, appt) =>
            sum! + appt.services.fold(0.0, (s, svc) => s + (svc.price ?? 0.0)),
      );
      invoice.amountPaid = 0.0;

      // Navigate to InvoiceScreen with appointments
      await Get.to(
        () => SaleEntryScreen(invoiceEntity: invoice),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete appointment: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEmployeeDialog(BuildContext context) {
    if (_selectedTimes.isEmpty || _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one time slot first'),
        ),
      );
      return;
    }

    // Initialize temporary assignments
    final tempSlotWorkerAssignments = Map<TimeOfDay, List<EmployeeEntity>>.from(
      _slotWorkerAssignments.map(
        (key, value) => MapEntry(key, List.from(value)),
      ),
    );
    for (final time in _selectedTimes) {
      tempSlotWorkerAssignments.putIfAbsent(time, () => []);
    }

    // Cache available employees per slot
    final slotAvailableEmployees = <TimeOfDay, List<EmployeeEntity>>{};
    for (final time in _selectedTimes) {
      final slot = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        time.hour,
        time.minute,
      );
      slotAvailableEmployees[time] = _getAvailableEmployees(slot);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: 400,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assign Stylists to Time Slots',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children:
                                _selectedTimes.map((time) {
                                  final slot = DateTime(
                                    _selectedDay!.year,
                                    _selectedDay!.month,
                                    _selectedDay!.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  final availableEmployees =
                                      slotAvailableEmployees[time]!;
                                  final selectedWorkers =
                                      tempSlotWorkerAssignments[time]!;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Slot: ${DateFormat.jm().format(slot)} (${selectedWorkers.length} selected)',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              selectedWorkers.isEmpty
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.error
                                                  : null,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (availableEmployees.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'No stylists available',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                            ),
                                          ),
                                        )
                                      else
                                        StatefulBuilder(
                                          builder: (context, setChipState) {
                                            return Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  availableEmployees.map((
                                                    employee,
                                                  ) {
                                                    final isSelected =
                                                        selectedWorkers.any(
                                                          (e) =>
                                                              e.id ==
                                                              employee.id,
                                                        );
                                                    return ChoiceChip(
                                                      key: ValueKey(
                                                        '${time.hour}:${time.minute}_${employee.id}',
                                                      ),
                                                      label: Text(
                                                        employee.name!,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              isSelected
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          color:
                                                              isSelected
                                                                  ? Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onPrimary
                                                                  : Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface,
                                                        ),
                                                      ),
                                                      selected: isSelected,
                                                      onSelected: (selected) {
                                                        setDialogState(() {
                                                          setChipState(() {
                                                            if (selected) {
                                                              selectedWorkers
                                                                  .add(
                                                                    employee,
                                                                  );
                                                            } else {
                                                              selectedWorkers
                                                                  .removeWhere(
                                                                    (e) =>
                                                                        e.id ==
                                                                        employee
                                                                            .id,
                                                                  );
                                                            }
                                                          });
                                                        });
                                                      },
                                                      selectedColor:
                                                          Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surfaceVariant,
                                                      elevation:
                                                          isSelected ? 4 : 0,
                                                      avatar:
                                                          isSelected
                                                              ? Icon(
                                                                Icons
                                                                    .check_circle,
                                                                size: 20,
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onPrimary,
                                                              )
                                                              : null,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        side: BorderSide(
                                                          color:
                                                              isSelected
                                                                  ? Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .outline,
                                                          width:
                                                              isSelected
                                                                  ? 2
                                                                  : 1,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            );
                                          },
                                        ),
                                      const Divider(height: 16),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final hasEmptySlots = tempSlotWorkerAssignments
                                  .values
                                  .any((workers) => workers.isEmpty);
                              if (hasEmptySlots) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please assign at least one stylist to each slot',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _slotWorkerAssignments.clear();
                                _slotWorkerAssignments.addAll(
                                  tempSlotWorkerAssignments,
                                );
                                _selectedEmployees =
                                    _slotWorkerAssignments.values
                                        .expand((workers) => workers)
                                        .toSet()
                                        .toList();
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Select Customer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Customer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    onChanged:
                        (val) =>
                            _customerController.getCustomersByNameOrMobile(val),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Obx(
                      () => Column(
                        children:
                            _customerController.customers.map((customer) {
                              return ListTile(
                                title: Text(customer.name!),
                                subtitle: Text(customer.phone ?? ''),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  child: Text(
                                    customer.name!.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() => _selectedCustomer = customer);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWaitlistDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Waitlist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _waitlistNotesController,
                    decoration: InputDecoration(
                      labelText: 'Waitlist Notes',
                      hintText: 'Enter waitlist details',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Obx(
                      () => Column(
                        children:
                            _appointmentsController.waitlist.map((
                              waitlistEntry,
                            ) {
                              return ListTile(
                                title: Text(
                                  waitlistEntry.customer.target?.name ??
                                      'Unknown',
                                ),
                                subtitle: Text(
                                  DateFormat.yMd().format(
                                    waitlistEntry.preferredDate!,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () {
                                    _appointmentsController.removeFromWaitlist(
                                      waitlistEntry,
                                    );
                                    setState(() {});
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _addToWaitlist,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Add to Waitlist'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Help'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How to book an appointment:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHelpItem('1. Select a date from the calendar'),
                _buildHelpItem('2. Choose available time slots'),
                _buildHelpItem('3. Select a customer from the list'),
                _buildHelpItem('4. Assign stylists to each time slot'),
                _buildHelpItem('5. Select services for the appointment'),
                _buildHelpItem('6. Add any notes and set reminder preferences'),
                _buildHelpItem('7. Click "Book Appointment" to confirm'),
                const SizedBox(height: 16),
                Text(
                  'Tips:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHelpItem('- Green dates have many available slots'),
                _buildHelpItem('- Yellow dates have limited availability'),
                _buildHelpItem('- Red dates are fully booked'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 8),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String get camelCase =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
