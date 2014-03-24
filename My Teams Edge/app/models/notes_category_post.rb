class NotesCategoryPost < ActiveRecord::Base

  #######################
  # constants
  #######################

  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :description, :opponent_id, :notes_categories_id, :user_id

  #######################
  # Associations
  #######################
  belongs_to :notes_category, :foreign_key => :notes_categories_id
  belongs_to :user

  has_many :comments, :as => :commentable

  ##########################
  # accept nested attrubutes
  ##########################

  #######################
  # Validations
  #######################
  validates :description, :presence => { :message => "^Description can't be blank" }
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

  #######################
  # Private methods
  #######################
  private

    def squish_fileds
      self.description.squish! if description.present?
    end

end
