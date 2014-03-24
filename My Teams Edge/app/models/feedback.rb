class Feedback
  include ActiveAttr::Model

  attribute :name
  attribute :email
  attribute :message
  attribute :organization
  attribute :reason

	attr_accessible :email, :message, :name, :organization, :reason

  ##################
  # Validations
  ##################
  validates :name, :presence => true
  validates :email, :presence => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, :allow_blank => true
  validates :message, :presence => true
  validates :reason, :presence => true
end
