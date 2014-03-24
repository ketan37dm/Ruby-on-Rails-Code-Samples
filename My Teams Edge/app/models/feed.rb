class Feed < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :activity_id, :user_id, :sport_id, :organization_id, :subvarsity_id

  #######################
  # Associations
  #######################

  belongs_to :activity
  belongs_to :user
  belongs_to :sport
  belongs_to :organization
  belongs_to :subvarsity


  ##########################
  # accept nested attrubutes
  ##########################

  #######################
  # Validations
  #######################

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

end
