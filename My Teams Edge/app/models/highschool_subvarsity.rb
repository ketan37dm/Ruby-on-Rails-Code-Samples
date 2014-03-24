class HighschoolSubvarsity < ActiveRecord::Base
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

  ##########################
  # accept nested attrubutes
  ##########################

  #######################
  # Validations
  #######################
  validates :name, :presence => { :message => "^Varsity name can't be blank" }
  before_validation :squish_fileds

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
  
    def squish_fileds
      self.name.squish! if !self.name.blank?
    end

  #######################
  # Private methods
  #######################
  private

end
