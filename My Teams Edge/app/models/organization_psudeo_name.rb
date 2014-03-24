class OrganizationPsudeoName < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :active, :name, :organization_id, :user_id, :sport_id, :subvarsity_id

  #######################
  # Associations
  #######################
  belongs_to :user

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :user_id, :presence => true
  validates :organization_id, :presence => true
  
  validates :name, :presence => {:message => "^Name can't be blank"}
  validates :name, :uniqueness => {
                                    :message => "^This name already taken",
                                    :scope => [:sport_id, :organization_id, :subvarsity_id]
                                  }

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
