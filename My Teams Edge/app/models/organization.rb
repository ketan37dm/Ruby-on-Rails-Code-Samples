class Organization < ActiveRecord::Base
  #attr_accessible :city, :name, :payer_id, :state, :team, :type

  #######################
  # constants
  #######################

  #######################
  # scopes
  #######################
  scope :upcoming_schedule, where("scheduled_at > #{Time.now}")

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################

  #######################
  # Associations
  #######################
  has_many :opponents
  has_many :subscriptions
  has_many :user_sports
  
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
  class << self
  end

  #######################
  #public methods
  #######################
  
  def active_sports
    user_sports.where(:role => "acc_owner");
  end

  ###################################
  # protected methods and call backs
  ###################################
  protected

  #######################
  # Private methods
  #######################
  private
end
