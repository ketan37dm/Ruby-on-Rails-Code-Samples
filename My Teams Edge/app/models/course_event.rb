class CourseEvent < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :creator_id, :title, :info, :date, :user_id

  #######################
  # Associations
  #######################
  belongs_to :course
  belongs_to :user

  ##########################
  # accept nested attrubutes
  ##########################

  #######################
  # Validations
  #######################
  validates :title, :presence => true
  validates :info, :presence => true
  validates :date, :presence => true
  validates :creator_id, :presence => true
  validates :user_id, :presence => true
  validate  :date_comparison, :if => Proc.new { |course_event| course_event.date.present? }

  #######################
  # Call backs
  #######################

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
    if self.date < Date.today
      self.errors.add(:date, "^Event date can't be lesser than todays date")
    end
  end

end
