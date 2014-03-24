class Address < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :street, :appartment, :city, :state, :zip, :creator_id, :category, :dorm

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
  validates :street, presence: true
  validates :category, presence: true
  validates :appartment, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true, numericality: true, allow_blank: true
  validates :dorm, presence: true, :if => Proc.new { |address| address.category == "school" }

  #######################
  # Call backs
  #######################

  #######################
  # Class Methods
  #######################

  #######################
  #public methods
  #######################
  def creator
    User.find(self.creator_id) rescue nil
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
