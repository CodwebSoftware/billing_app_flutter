import 'package:billing_app_flutter/db/models/appointment_entity.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/db/models/waitlist_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';
import 'package:objectbox/objectbox.dart';

class AppointmentsController extends GetxController {
  final ObjectBoxes objectBox;

  final RxList<AppointmentEntity> appointments = <AppointmentEntity>[].obs;
  final RxList<WaitlistEntity> waitlist = <WaitlistEntity>[].obs;

  AppointmentsController({required this.objectBox});

  getAppointmentsByCustomer(int customerId) {
    final query = objectBox.appointmentBox
        .query(AppointmentEntity_.client.equals(customerId))
        .build();
    final results = query.find();
    for (var appt in results) {
      appt.employees; // Load employees relation
      appt.services; // Load services relation
    }
    appointments.assignAll(results);
    query.close();
  }

  List<AppointmentEntity> getAppointmentsByDate(DateTime date) {
    final query = objectBox.appointmentBox
        .query(
      AppointmentEntity_.dateTime.between(
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
        DateTime(date.year, date.month, date.day, 23, 59).millisecondsSinceEpoch,
      ),
    )
        .build();
    final results = query.find();
    for (var appt in results) {
      appt.employees; // Load employees relation
      appt.services; // Load services relation
    }
    query.close();
    return results;
  }

  AppointmentEntity? getAppointment(int id) {
    final appointment = objectBox.appointmentBox.get(id);
    if (appointment != null) {
      appointment.employees; // Load employees relation
      appointment.services; // Load services relation
    }
    return appointment;
  }

  saveAppointment(AppointmentEntity appointment) {
    objectBox.appointmentBox.put(appointment);
    update();
  }

  addToWaitlist(
      CustomerEntity customer,
      DateTime preferredDate,
      String notes,
      List<ServiceEntity> services,
      ) {
    final waitlistEntry = WaitlistEntity();
    waitlistEntry.preferredDate = preferredDate;
    waitlistEntry.notes = notes;
    waitlistEntry.customer.target = customer;
    if (services.isNotEmpty) {
      waitlistEntry.services.addAll(services);
    }

    objectBox.waitListBox.put(waitlistEntry);
    waitlist.add(waitlistEntry);
    update();
  }

  void removeFromWaitlist(WaitlistEntity waitlistEntry) {
    objectBox.waitListBox.remove(waitlistEntry.id);
    waitlist.remove(waitlistEntry);
    update();
  }

  void cancelAppointment(AppointmentEntity appointment) {
    objectBox.appointmentBox.put(appointment, mode: PutMode.update);
    update();
  }

  void rescheduleAppointment(
      AppointmentEntity appointment,
      DateTime newDateTime,
      ) {
    appointment.dateTime = newDateTime;
    objectBox.appointmentBox.put(appointment);
    update();
  }
}
