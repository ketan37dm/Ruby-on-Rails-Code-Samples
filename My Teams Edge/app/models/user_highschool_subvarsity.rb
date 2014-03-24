class UserHighschoolSubvarsity < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :high_school_id, :name, :sport_id, :active, :set_account_deletion

  #######################
  # Associations
  #######################

  ##########################
  # accept nested attrubutes
  ##########################

  #######################
  # Validations
  #######################
  validates :name,            :presence => { :message => "^Varsity name can't be blank" }
  validates :high_school_id,  :presence => true
  validates :sport_id,        :presence => true

  before_validation           :squish_fileds

  #######################
  # Call backs
  #######################

  #######################
  # Class Methods
  #######################

  def self.sub_varsities_for(sport_id, high_school_id)
    self.select("name, id").where(
        :sport_id => sport_id,
        :high_school_id => high_school_id
      ).all
  end

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
