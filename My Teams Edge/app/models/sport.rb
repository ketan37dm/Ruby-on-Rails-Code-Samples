class Sport < ActiveRecord::Base

  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :name

  #######################
  # Associations
  #######################
  has_many :sports_units

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################

  #######################
  # Call backs
  #######################

  #######################
  # Class Methods
  #######################
  def self.without_football
    where("name != 'Football'")
  end

  def self.football
    find_by_name('football')
  end

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
