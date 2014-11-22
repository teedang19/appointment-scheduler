class Appointment < ActiveRecord::Base
  before_validation :set_end_time

  validates_presence_of :appointment_category_id, :availability_id, :instructor_id, :start_time, :end_time, :status
  validates_presence_of :user_id, unless: Proc.new { |record| record.open? }

  # TODO auto-maintaining the status of appointments

  # TODO when an appointment is cancelled or rescheduled, another one needs to be made that is identical to it that is Open. TIME OVERLAPS. "bookable" scope?
  validates :status, inclusion: { in: ["Open", "Future", "Past - Occurred", "Cancelled by Student", "Cancelled by Instructor", "Rescheduled by Student", "Rescheduled by Instructor", "No Show", "Unavailable"] }
  validates :re_bookable, inclusion: { in: [true, false] }

  validate :end_time_must_be_after_start_time
  validate :start_time_cannot_be_in_past, on: :create

  # LOGIC MAGIC: (end_time is greater than start_time) && (start_time is less than end_time)
  validates :start_time, :end_time, :overlap => {
    scope: "instructor_id",
    :query_options => { :active => nil }, # for Rebookings, dead appointments
    exclude_edges: ["start_time", "end_time"],
    message_title: :base,
    :message_content => "Time slot overlaps with instructor's other appointments."
  }

  validates :start_time, :end_time, :overlap => {
    scope: "user_id",
    :query_options => { :active => nil }, # for Rebookings, dead appointments
    exclude_edges: ["start_time", "end_time"],
    message_title: :base,
    :message_content => "Time slot overlaps with student's other appointments."
  }, unless: Proc.new { |record| record.open? }

  belongs_to :appointment_category
  belongs_to :availability
  belongs_to :user
  belongs_to :instructor, class_name: "User"

  has_one :rebooking, foreign_key: "dead_appointment_id"
  has_one :rebooked_appointment, through: :rebooking, source: :new_appointment

  has_one :reverse_rebooking, class_name: "Rebooking", foreign_key: "new_appointment_id"
  has_one :original_appointment, through: :reverse_rebooking, source: :dead_appointment

  scope :active, -> { where(re_bookable: false) }
  scope :today, -> { where('start_time > ?', Date.today.beginning_of_day).where('end_time < ?', Date.today.end_of_day) } # TODO edgecase: overnight appt. assumes UTC time

  def end_time_must_be_after_start_time
    errors.add(:end_time, "must be after start time.") unless end_time > start_time
  end

  def start_time_cannot_be_in_past
    errors.add(:start_time, "cannot be in the past") unless start_time >= (DateTime.now - 5.minutes)
  end

  def name
    "##{id}"
  end

  def set_end_time
    self.end_time = (self.start_time + self.appointment_category.total_duration.minutes)
  end

  def lesson_duration
    appointment_category.lesson_minutes
  end

  def buffer_duration
    appointment_category.buffer_minutes
  end

  def total_duration
    appointment_category.total_duration
  end

  def end_time
    start_time + total_duration.minutes
  end

  def open?
    status == "Open" || user_id.nil?
  end

  def future?
    status == "Future"
  end

  def unavailable?
    status == "Unavailable"
  end

  def editable_status_by_instructor?
    open? || future? || unavailable?
  end

  rails_admin do

    list do
      field :id
      field :instructor
      field :user do
        label do
          "Student"
        end
      end
      field :start_time
      field :appointment_category
      field :status
    end

    show do
      field :id
      field :instructor
      field :user do
        label do
          "Student"
        end
      end
      field :appointment_category
      field :start_time
      field :end_time
      field :status
      field :availability
      field :created_at do
        visible do
          bindings[:view].current_user.admin?
        end
      end
      field :updated_at do
        visible do
          bindings[:view].current_user.admin?
        end
      end
    end

    edit do
      field :instructor do
        inline_add false
        inline_edit false

        visible do
          bindings[:view].current_user.admin?
        end

        associated_collection_scope do
          Proc.new { |scope| scope = scope.where(instructor: true) }
        end
      end

      field :user do
        inline_add false
        inline_edit false

        label do
          "Student"
        end

        read_only do
          !(bindings[:view].current_user.admin?)
        end

        help do
          !(bindings[:view].current_user.admin?) ? "" : "#{help}"
        end

        associated_collection_scope do
          Proc.new { |scope| scope = scope.where(instructor: false).where(admin: false) }
        end
      end

      field :appointment_category do
        inline_add false
        inline_edit false

        read_only do
          !(bindings[:view].current_user.admin?)
        end

        help do
          !(bindings[:view].current_user.admin?) ? "" : "#{help}"
        end
      end

      field :start_time do
        read_only do
          !(bindings[:view].current_user.admin?)
        end

        help do
          !(bindings[:view].current_user.admin?) ? "" : "#{help}"
        end
      end
      
      field :status, :enum do
        read_only do
          !(bindings[:view].current_user.admin?) && !(bindings[:object].editable_status_by_instructor?)
        end
        
        enum do
          ["Open", "Future", "Past - Occurred", "Cancelled by Student", "Cancelled by Instructor", "Rescheduled by Student", "Rescheduled by Instructor", "No Show", "Unavailable"]
        end

        help do
          "Required. An appoinment marked 'Unavailable' will not be reserve-able by any Students."
        end
      end
    end
  end
end