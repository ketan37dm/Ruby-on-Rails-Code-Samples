class UserUpdate < ActiveRecord::Base

  include ModelHelpers::ActivityLogger

  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################
  attr_accessor :update_on

  #######################
  # attribute accessibles
  #######################
  attr_accessible :sport_id, :text, :user_id, :update_on, :custom_sports_unit_ids,
                  :user_ids, :organization_id, :subvarsity_id

  #######################
  # Associations
  #######################
  belongs_to :user
  belongs_to :custom_sports_unit
  belongs_to :sport
  belongs_to :organization

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :user_id, :presence => true
  validates :sport_id, :presence => true

  validates :text, :presence => { :message => "^Message can't be blank" }
  validate :share_with
  #######################
  # Call backs
  #######################

  after_create :log_activity

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

  def log_activity

    add_activities(:resourceable => self, :user => self.user)

    #user_ids = (self.user_ids + (CustomSportsUnit.for_ids(self.custom_sports_unit_ids)
                                 #.includes(:user_sports_units)
                                 #.map { |csu| csu.user_sports_units.collect(&:user_id) }.flatten)).try(:uniq)
    #Activity.create(:user_id => self.user_id, :data_type => self.class.to_s,
                    #:data => {:data_id => self.id, :data_message => self.text, :data_type => self.class.to_s },
                    #:sport_id => self.sport_id, :organization_id => self.organization_id, 
                    #:subvarsity_id => self.subvarsity_id,
                    #:user_ids => user_ids)
  end

end
