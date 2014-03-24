class PitchRequest < ActiveRecord::Base
  attr_accessible :details, :url, :email,:category_id, :user_id

  belongs_to :user
  belongs_to :category

  validates :details, :presence => true
  validates :email, :presence => true
  validates :category_id, :presence => true
  
  VALID_URL_REGEX_SET = /^(https?:\/\/(w{3}\.)?)|(w{3}\.)|[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\s]*)?/ix
  validates :url, :format => {:allow_blank => true, :with => VALID_URL_REGEX_SET}

  validates :email, :format => {:with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i}

  after_save :send_email

  private
  def send_email
    PitchRequestNotification.delay.pitch_creation_request(self)
  end
end
