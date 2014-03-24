class Follow < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :follower_id, :following_id, :organization_id, :sport_id, :subvarsity_id

  #######################
  # Associations
  #######################

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :follower_id, :presence => true
  validates :following_id, :presence => true
  validates :organization_id, :presence => true
  validates :sport_id, :presence => true

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
