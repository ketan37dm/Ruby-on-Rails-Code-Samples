class HighSchool < Organization
  ###############
  # constants
  ###############

  ########################
  # attribute accessors
  ########################


  ########################
  # attribute accessibles
  ########################
  attr_accessible :name, :city, :state


  ##################
  # Associations
  ##################
  has_many :user
  belongs_to :payer


  ##################
  # Validations
  ##################
  validates_presence_of :name, :message => "^High school name can't be blank"
  validates :city, :presence => true
  validates :state, :presence => true

  ##################
  # Call backs
  ##################

  before_validation :squish_fileds

  ##################
  # Class Methods
  ##################

  ##################
  #public methods
  ##################


  ###################################
  # protected methods and call backs
  ###################################
  protected

    def squish_fileds
      self.name.squish! unless self.name.blank?
      self.city.squish! unless self.city.blank?
      self.state.squish! unless self.state.blank?
    end

  ##################
  # Private methods
  ##################
  private

end
