class UserSportsUnit < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :custom_sports_unit_id, :user_id

  #######################
  # Associations
  #######################
  belongs_to :user
  belongs_to :custom_sports_unit

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################

  #######################
  # Call backs
  #######################
  before_save :unit_already_assigned?

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

    def unit_already_assigned?
      if self.class.where(custom_sports_unit_id: self.custom_sports_unit_id, user_id: self.user_id).count > 0
        errors.add(:base, "Already in the unit")
        return false
      else
        return true
      end
    end

  #######################
  # Private methods
  #######################
  private

end
