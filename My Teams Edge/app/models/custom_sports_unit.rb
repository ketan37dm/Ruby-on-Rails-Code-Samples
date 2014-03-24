class CustomSportsUnit < ActiveRecord::Base
  #######################
  # constants
  #######################
  attr_accessible :sport_id, :unit_name, :user_id, :organization_id, :subvarsity_id

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################

  #######################
  # Associations
  #######################
  belongs_to :user
  has_many :user_sports_units, :dependent => :destroy

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :unit_name, :presence => {:messsage => "^Unit name can't be empty"}
  validates :unit_name, :format => {  :with => /\A[a-zA-Z0-9_\s]+\z/,
                                      :message => "^Invalid name" }

  #######################
  # Call backs
  #######################
  before_save :prevent_duplicate_unitnames
  before_validation :squish_fields


  #######################
  # Class Methods
  #######################

  def self.units_for_sport(current_sport, organization, subvarsity_id = nil)
    units = CustomSportsUnit.where(
        :sport_id         => current_sport.id,
        :organization_id  => organization.id,
        :subvarsity_id    => subvarsity_id
      ).where("custom_sports_units.unit_name not in ('#{[User::ROLES[:coach], User::ROLES[:player], User::ROLES[:aux_user]].join("','")}')")

    return units
  end

  def self.for_ids(ids)
    where(:id => ids)
  end

  def self.search(query)
    like = "%".concat(query.concat("%"))
    where("unit_name like ?", like)
  end

  #######################
  #public methods
  #######################
  
  ###################################
  # protected methods and call backs
  ###################################
  protected

    def prevent_duplicate_unitnames
      existing_count = self.class.where(sport_id: self.sport_id, organization_id: self.organization_id, unit_name: self.unit_name, subvarsity_id: self.subvarsity_id).count
      if existing_count > 0
        self.errors.add(:unit_name, "^Already exists")
        return false
      else
        return true
      end
    end

    def squish_fields
      self.unit_name.squish! if self.unit_name.present?
    end

  #######################
  # Private methods
  #######################
  private

end
