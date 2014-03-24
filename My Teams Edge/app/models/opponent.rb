class Opponent < ActiveRecord::Base
  #######################
  # constants
  #######################
  Locations = {
    home: "Home",
    away: "Away"
  }

  Types = {
    conference: "Conference",
    non_conf: "Non Conf"
  }

  #######################
  # attribute accessors
  #######################
  attr_accessor :update_on, :event_at

  #######################
  # attribute accessibles
  #######################
  attr_accessible :event_type, :location, :name, :scheduled_at, :update_on, :sport_id, :user_id, 
                  :event_at, :organization_id, :subvarsity_id


  #######################
  # Associations
  #######################
  belongs_to :user
  belongs_to :sport
  belongs_to :organization

  ##########################
  # accept nested attrubutes
  ##########################

  ##########################
  # include modules
  ##########################
  include ModelHelpers::StringToDatetime

  #######################
  # Validations
  #######################
  validates :name, :presence => {:message => "^Name can't be empty"}
  validates :location, :presence => {:message => "^Please select location"}
  validates :event_type, :presence => {:message => "^Please select type"}
  before_validation :check_scheduled_time

  #######################
  # Call backs
  #######################

  #######################
  # Class Methods
  #######################

  def self.search(query)
    like = "%".concat(query.concat("%"))
    where("name like ?", like)
  end

  #######################
  #public methods  
  #######################
  def notes_categories
    
    return NotesCategory.where(
        :sport_id           => sport_id,
        :subvarsity_id      => subvarsity_id,
        :organization_id    => organization_id,
        :opponent_name      => name
      ).order("created_at DESC")

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
