class NotesCategory < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :name, :opponent_name, :sport_id, :organization_id, :subvarsity_id

  #######################
  # Associations
  #######################
  has_many :notes_category_posts, :foreign_key => :notes_categories_id

  ##########################
  # accept nested attrubutes
  ##########################

  #######################
  # Validations
  #######################
  validates :name, :presence => { :message => "^Name required" }
  validates :name, :uniqueness => {
                                    :message => "^This name already taken",
                                    :scope => [ 
                                                :opponent_name,
                                                :sport_id, 
                                                :organization_id, 
                                                :subvarsity_id
                                              ]
                                  }

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
      self.name.squish! if name.present?
      self.opponent_name.squish! if opponent_name.present?      
    end
end
