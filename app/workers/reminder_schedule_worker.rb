class ReminderScheduleWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    Appointment.booked_tomorrow.each do |appt|
      ReminderEmailWorker.perform_async(appt.id)
      Sidetiq.logger.info("ReminderEmailWorker called for Appointment with ID #{appt.id}")
    end
  end
end