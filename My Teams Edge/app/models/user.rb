class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable, :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable



  ###############
  # constants
  ###############

  ROLES = { admin: 'admin', acc_owner: 'acc_owner', coach: 'coach',
            player: 'player', aux_user: 'aux_user' }

  
  STRIPE_PLAN_IDS = %w(elite_edge football_edge highschool_edge)


  FEED_SIZE = 10


  ########################
  # attribute accessors
  ########################
  attr_accessor :validate_level, :validate_university, :name, :city, :state,
                :organization_name, :update_on, :sport_id, :user_sports_attributes,
                :new_sport_added, :current_password, :role


  ########################
  # attribute accessibles
  ########################
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
    :stripe_token, :stripe_plan_id, :university_id, :sport_id, :level, :role,
    :first_name, :last_name, :name, :city, :state, :payer_email, :accepted_terms_and_conditions,
    :organization_name, :update_on, :user_sports_attributes, :high_school_id, :sport_id, :image,
    :phone, :cell, :image, :current_password, :new_email, :personal_info_attributes,
    :courses_attributes


  ########################
  # Paper clip attributes
  ########################
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "96x96>" },
    :url  => "/system/images/:id/:style/:basename.:extension",
    :path => "public/system/images/:id/:style/:basename.:extension",
    :default_url => "/assets/missing.png"

  ##################
  # Associations
  ##################
  include ModelExtentions::UserAssociations

  ##########################
  # accept nested attrubutes
  ###########################
  accepts_nested_attributes_for :user_sports, :allow_destroy => true
  accepts_nested_attributes_for :personal_info, :allow_destroy => true 
  accepts_nested_attributes_for :courses, :allow_destroy => true

  ##################
  # Validations
  ##################
  include ModelExtentions::UserValidations

  ##################
  # Call backs
  ##################
  include ModelExtentions::UserCallbacks

  ##################
  # Class Methods
  ##################
  include ModelExtentions::UserClassMethods
    
  ##################
  #public methods
  ##################
  include ModelExtentions::UserPublicMethods
  
  ###################################
  # protected methods and call backs
  ###################################
  include ModelExtentions::UserCallbackMethods

  ##################
  # Private methods
  ##################
  include ModelExtentions::UserPrivateMethods

end
