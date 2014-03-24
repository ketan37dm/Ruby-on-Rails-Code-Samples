class PersonalContact < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :user_id, :creator_id, :relationship, :email, :phone, :name

  #######################
  # Associations
  #######################
  belongs_to :user
  has_many :comments, :as => :commentable

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :relationship, :presence => true
  validates :user_id, :presence => true
  validates :creator_id, :presence => true
  validates :name, :presence => true
  validates :email, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, :allow_blank => true

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
