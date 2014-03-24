class Comment < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :content, :commentator_id, :commentable_id, :commentable_type

  #######################
  # Associations
  #######################
  belongs_to :commentable, :polymorphic => true
  belongs_to :user, :foreign_key => :commentator_id

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :content, :presence => { :message => "^Comment can't be blank" } 
  validates :commentator_id, :presence => true
  
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
