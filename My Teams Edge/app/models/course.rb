class Course < ActiveRecord::Base
  attr_accessible :name, :professor, :room_number, :user_id,
    :user_sport_id, :creator_id, :start_date, :end_date, :weekdays

  #######################
  # constants
  #######################

  #######################
  # serialize
  #######################
  serialize :weekdays, Array

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################

  #######################
  # Associations
  #######################
  has_many :comments, :as => :commentable
  has_many :documents
  has_many :course_events
  belongs_to :user

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :name, presence: true
  validates :start_date, presence: { message: "^Please select a Start Date" }
  validates :end_date, presence: { message: "^Please select an End Date" }
  #validates :weekdays, presence: { message: "^Please select teaching days for course" }

  #######################
  # Call backs
  #######################
  validate :date_comparison, :if => Proc.new { |course| course.start_date.present? && course.end_date.present? } 
  #######################
  # Class Methods
  #######################

  #######################
  #public methods
  #######################
  
  ###################################
  # protected methods and call backs
  ###################################
  protected

  #######################
  # Private methods
  #######################
  private

  def date_comparison
    if self.start_date > self.end_date
      self.errors.add(:base, "Start date can't exceed end date")
    end
  end

end
