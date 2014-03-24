class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, and :omniauthable, :trackable 
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable #, :confirmable
  
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :web_address, :current_password
  
  ###############  validations  ###############
  validates :name, :presence => true
  VALID_URL_REGEX_SET = /^(https?:\/\/(w{3}\.)?)|(w{3}\.)|[a-z0-9]+(?:[\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(?:(?::[0-9]{1,5})?\/[^\s]*)?/ix
  validates :web_address, :format => {:allow_blank => true, :with => VALID_URL_REGEX_SET}
  
  ###############  associations  ##############
  has_many :authentications, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :pitch_requests
  has_one :pitch, :dependent => :destroy
  has_many :poll_results, :dependent => :destroy
  
  ################  callbacks  ################
  before_create :set_identifier
  after_create :registration_note

  ################  public  ###################
  handle_asynchronously :send_reset_password_instructions

  def company_present?
    web_address.present?
  end

  def pitch_created?
    !(pitch.new_record?) rescue false
  end

  def add_link
    if self.web_address.include?("http") || self.web_address.include?("https")
      self.web_address
    else
      "http://#{self.web_address}"
    end
  end

  def pitch_rank
    Pitch.rank(self)
  end

  def pitch_likes
    return 0 unless pitch
    pitch.likes_count
  end

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def validate_is_individual(flag)
    if flag == false
      errors.add(:is_individual, "^Your Status must be selected")
    end
  end
  
  def get_authentications
    providers = ""
    self.authentications.each{ |a| providers += a.provider.humanize + ", " }
    return providers.chomp!(", ")
  end

  def set_identifier
    pass = Devise.friendly_token[0,20] 
    while !User.where(identifier: pass).first.blank?
      pass = Devise.friendly_token[0,20]
    end    
    self.identifier = Devise.friendly_token[0,20]
  end

  # returns false when user signs in through twitter
  def email_required?
    (authentications.empty?) && super
  end

  # can be used for skipping password validation of devise
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
  
  def social_signin?
    self.authentications.present?
  end

  private
  def registration_note
    Registration.delay.note(self)
  end
end
