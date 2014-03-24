class UserEvent < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################
  attr_accessor :update_on, :event_at

  #######################
  # attribute accessibles
  #######################
  attr_accessible :custom_sports_unit_id, :scheduled_at, :sports_id, :title, :user_id, :event_at,
                  :sport_id, :update_on, :organization_id, :subvarsity_id, :custom_sports_unit_ids,
                  :user_ids

  #######################
  # Associations
  #######################
  belongs_to :user
  belongs_to :sport
  belongs_to :organization

  ##########################
  # accept nested attrubutes
  ##########################

  ##########################
  # include modules
  ##########################
  include ModelHelpers::StringToDatetime

  #######################
  # Validations
  #######################
  validates :user_id, :presence => true
  validates :sport_id, :presence => true

  validates :title, :presence => {:message => "^Title can't be blank"}

  validate :share_with
  before_validation :check_scheduled_time

  #######################
  # Call backs
  #######################
  
  after_create :create_activity


  #######################
  # Serialize
  #######################

  serialize :custom_sports_unit_ids, Array
  serialize :user_ids, Array

  #######################
  # Class Methods
  #######################

  #######################
  #public methods
  #######################

  def due_day
    return :today if self.scheduled_at.between?(Date.today.beginning_of_day, Date.today.end_of_day)
    return :tomorrow if self.scheduled_at.between?(Date.tomorrow.beginning_of_day, Date.tomorrow.end_of_day)
    return :overmorrow if self.scheduled_at.between?((Date.tomorrow + 1).beginning_of_day, (Date.tomorrow + 1).end_of_day)
  end

  ###################################
  # protected methods and call backs
  ###################################
  protected

  #######################
  # Private methods
  #######################
  private

  def share_with
    errors.add(:base, "share with can't be blank") if !self.custom_sports_unit_ids.present? && !self.user_ids.present?
  end


  def create_activity
    debugger
    user_ids = (self.user_ids + (CustomSportsUnit.for_ids(self.custom_sports_unit_ids)
                                 .includes(:user_sports_units)
                                 .map { |csu| csu.user_sports_units.collect(&:user_id) }.flatten)).try(:uniq)
    Activity.create(:user_id => self.user_id, :data_type => self.class.to_s,
                    :data => {:data_id => self.id, :data_message => self.title, :at => self.scheduled_at, :data_type => self.class.to_s },
                    :sport_id => self.sport_id, :organization_id => self.organization_id, 
                    :subvarsity_id => self.subvarsity_id,
                    :user_ids => user_ids)
  end


end
