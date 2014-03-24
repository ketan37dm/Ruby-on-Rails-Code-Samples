class Quote < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :date, :content, :author

  #######################
  # Associations
  #######################
  belongs_to :admin, :dependent => :destroy

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################
  validates :date, :presence => true
  validates :content, :presence => true
  validates :author, :presence => true

  #######################
  # Call backs
  #######################

  #######################
  # Class Methods
  #######################
  
  def self.quote_for_today
  	#return quote if found for todays date
  	#if not found for todays date - return the previous availabe
  	Quote.where("date <= ?", Time.now).order(:date).last
	end

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
