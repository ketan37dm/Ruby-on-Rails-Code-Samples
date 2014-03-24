class UserSport < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # serialize attributes
  #######################
  serialize :created_by

  #######################
  # attribute accessors
  #######################
  attr_accessor :skip_check_user_sport

  #######################
  # attribute accessibles
  #######################
  attr_accessible :sport_id, :sport_name, :user_id, :payer_id, :role, :created_by,
                  :subvarsity_id, :subvarsity_name, :organization_id, :confirmed_at,
                  :confirmation_identifier, :parent_id

  #######################
  # Associations
  #######################:add_new_account_manager,
  belongs_to :user
  belongs_to :sport
  belongs_to :payer
  belongs_to :organization

  ##########################
  # accept nested attrubutes
  ###########################

  #######################
  # Validations
  #######################

  validates :sport_id, :presence => true
  validate :check_user_with_sport, :if => "subvarsity_id.blank? and !skip_check_user_sport"
  validates :role, :presence =>{ :message => '^Please select a role' }

  #######################
  # Call backs
  #######################
  after_create :create_custom_sports_units_for_user, :if => :user_acc_owner?
  after_create :create_psudeo_ogranization_entry, :if => :user_acc_owner?
  after_create :create_user_default_sport_units, :if => Proc.new{|user_sport| user_sport.role != User::ROLES[:acc_owner]}
  after_create :create_subvarsities, :if => :user_acc_owner_and_not_subvarsity_owner? and :owner_from_highschool?
  after_create :sport_added_notification

  #######################
  # Class Methods
  #######################
  include ModelExtentions::UserSports::ClassMethods

  #######################
  #public methods
  #######################

  def to_s
    str = ""
    str << "#{payer.subscription.stripe_plan_id.titleize} (#{sport.name})" rescue ""
    str << " - #{subvarsity_name} - Subvarsity" if subvarsity_name.present?
    str
  end

  def package_details
    @payer = payer
    @user = user
    @subscription = payer.subscription

    {
      :account_created => (@subscription.created_at rescue nil),
      :payer => ("#{@payer.full_name} (#{@payer.email})" rescue nil),
      :payer_type => @subscription.customer_id.present? ? "Credit Card" : "Admin Created",
      :account_owner => ("#{@user.full_name} (#{@user.email})" rescue nil ),
      :coach_accounts_count => accounts_count_for(User::ROLES[:coach]) + 1,
      :player_accounts_count => accounts_count_for(User::ROLES[:player]),
      :auxiliary_accounts_account => accounts_count_for(User::ROLES[:aux_user])
    }

  end

  def accounts_count_for(role)
    UserSport.where(:sport_id => self.sport.id,
                    :organization_id => self.organization_id,
                    :role => role,
                    :subvarsity_id => self.subvarsity_id).count
  end

  def reset_users_custom_sports_units
    if $PROGRAM_NAME.end_with?('rake')
      CustomSportsUnit.delete_all
      user_sports = UserSport.includes(:user).where("user_sports.role = 'coach' or user_sports.role='acc_owner'")
      user_sports.each do |user_sport|
        organization_id = user_sport.user.organization.id
        user_sport.sport.sports_units.each { |sport_unit|
          CustomSportsUnit.create(
                                    sport_id: user_sport.sport_id, 
                                    user_id: user_sport.user_id, 
                                    unit_name: sport_unit.unit_name, 
                                    organization_id: organization_id
                                  )
        }
      end
    else
      raise "Unknown operation"
    end

  end

  def subvarsity_accounts
    user_sports = UserSport.where(:sport_id => self.sport_id, :organization_id => self.organization_id)
    user_sports.select { |us| us.subvarsity_id.present? && us.role == User::ROLES[:acc_owner] }
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm
    self.skip_check_user_sport = true
    update_attribute(:confirmed_at, Time.now)
  end

  def generate_confirmation_identifier
    self.skip_check_user_sport = true
    self.update_attribute(:confirmation_identifier, Devise.friendly_token[0,25]) if confirmation_identifier.blank?
    return confirmation_identifier
  end
  
  ###################################
  # protected methods and call backs
  ###################################
  protected

    def create_custom_sports_units_for_user
      organization_id = self.user.organization.id

      self.sport.sports_units.each { |sport_unit| 

        CustomSportsUnit.create(
                                  sport_id: self.sport_id, 
                                  user_id: self.user_id, 
                                  unit_name: sport_unit.unit_name, 
                                  organization_id: organization_id,
                                  subvarsity_id: self.subvarsity_id
                                )
      }
    end

    def create_psudeo_ogranization_entry
      organization = self.user.organization
      OrganizationPsudeoName.create(
                                      sport_id: self.sport_id,
                                      organization_id: organization.id,
                                      user_id: self.user_id,
                                      name: organization.name,
                                      active: true,
                                      subvarsity_id: self.subvarsity_id
                                    )
    end

    def user_acc_owner? 
      self.role == User::ROLES[:acc_owner]
    end

    def create_user_default_sport_units
      organization_id = self.user.organization.id
      custom_sports_unit = CustomSportsUnit.where(
                                unit_name: self.role,
                                sport_id: self.sport_id,
                                organization_id: organization_id,
                                subvarsity_id: self.subvarsity_id
                              ).first

      if custom_sports_unit.present?
        UserSportsUnit.create(
                      user_id: self.user_id,
                      custom_sports_unit_id: custom_sports_unit.id
                    )
      end
    end

    def create_subvarsities
      high_school_id = self.user.organization.id

      HighschoolSubvarsity.pluck(:name).map { |name| 
        UserHighschoolSubvarsity.create(name: name, sport_id: self.sport_id, high_school_id: high_school_id)
      }
    end

    def user_acc_owner_and_not_subvarsity_owner?
      self.user_acc_owner? && self.subvarsity_id.blank?
    end

    def owner_from_highschool?
      self.user.organization.is_a?(HighSchool)
    end



  #######################
  # Private methods
  #######################
  private

    def sport_added_notification
      if user.user_sports.count > 1 && (skip_check_user_sport || subvarsity_id.present?)
        NotificationMailer.send_sport_added_notification(user, self).deliver
      end
    end

    def check_user_with_sport
      if UserSport.where(:sport_id => self.sport_id, :user_id => self.user_id, :subvarsity_id => self.subvarsity_id).present?
        self.errors.add(:base, "Sport is already assigned to this user")
      end
    end


end
