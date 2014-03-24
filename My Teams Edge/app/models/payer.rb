class Payer < ActiveRecord::Base
   ###############
  # constants
  ###############


  ########################
  # attribute accessors
  ########################
  attr_accessor :stripe_token, :stripe_plan_id, :credit_card, :cvv, :card_month,
                :card_year, :expiration_date, :is_same_user, :organization_name,
                :level, :city, :state, :update_on, :user_first_name, :user_last_name,
                :user_email, :user_sport_id, :account_errors, :created_by


  ########################
  # attribute accessibles
  ########################
  attr_accessible :email, :first_name, :last_name, :high_school_attributes,
                  :stripe_token, :credit_card, :cvv, :card_month, :card_year, :stripe_plan_id,
                  :is_same_user, :organization_name, :level, :city, :state, :user_first_name,
                  :user_last_name, :user_email, :user_sport_id, :created_by


  ##################
  # Associations
  ##################
  has_one  :subscription, :dependent => :destroy
  has_one  :high_school, :dependent => :destroy
  has_one  :other_organization, :dependent => :destroy
  has_many :user_sports, :dependent => :destroy

  ##########################
  # accept nested attrubutes
  ###########################

  accepts_nested_attributes_for :high_school, :allow_destroy => true
  accepts_nested_attributes_for :other_organization, :allow_destroy => true

  ##################
  # Validations
  ##################
  validates :email, :presence => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, :allow_blank => true
  validate :university_college_name, :if => Proc.new{ |payer| payer.level == LEVELS[:college]}
  validate :basic_info, :if => Proc.new{ |payer| payer.level.present?}

  ##################
  # Call backs
  ##################

  #after_create :create_organization, :if => Proc.new { |payer| payer.level.present?}
  #before_validation :set_payer_as_same_user

  before_save :update_stripe, :unless => Proc.new { |payer| payer.created_by.try(:to_sym) == :admin }

  after_create :create_subscription
  after_create :notify_admin_regarding_account_creation

  ##################
  # Class Methods
  ##################

  ##################
  #public methods
  ##################

  # returns the organization_name for which payment is done
  def associated_organization
    user_sports.first.user.organization 
  end

  def full_name
    "#{self.first_name.capitalize} #{self.last_name.capitalize}"
  end
  

  def set_payer_as_same_user(user)
    if is_same_user == 'yes'
      user = user
      self.email = user.email
      self.first_name = user.first_name
      self.last_name = user.last_name
    end
  end

  def create_elite_edge
    create_account
  end

  def create_football_edge
    create_account
  end

  def create_organization(user)
    @user = user 
    if level.present? && organization_name.present?
      if level == LEVELS[:college]
        set_university_to_user
      elsif level == LEVELS[:high_school]
        create_high_school_and_add_to_user
      else
        create_other_organization_and_add_to_user
      end
    end
    @user.save
  end

  def update_stripe
    if self.subscription.nil?
      if !self.stripe_token.present?
        raise "Stripe token not present. Can't create account."
      end
      @customer = Stripe::Customer.create(
        :email =>  self.email,
        :description => self.email,
        :card => self.stripe_token,
        :plan => self.stripe_plan_id
      )
    else
      @customer = Stripe::Customer.retrieve(subscription.customer_id)
      if self.stripe_token.present?
        @customer.card = self.stripe_token
      end
      @customer.email = self.email
      @customer.description = self.email
      @customer.save
    end
    rescue Stripe::StripeError => e
      logger.error e.message
      errors.add :elite_edge_errors, "Unable to create your subscription. #{e.message}"
      self.stripe_token = nil
      false
  end

  def create_subscription
    if self.valid?
      hash_option = {:stripe_plan_id => self.stripe_plan_id, :expires_at => DateTime.now + 1.year}
      if self.created_by.try(:to_sym) != :admin
       hash_option = hash_option.merge(:last_4_digits => @customer.active_card.last4, :customer_id => @customer.id)
      end

      self.create_subscription!(hash_option)
    end
    #send email to the payer
    NotificationMailer.delay.payment_invoice(self)
  end

  #check if payer has enetered the correct details not
  def valid_with_credit_card?
    self.valid?
    errors.add(:credit_card, "can't be blank") if self.credit_card == "0" || 
                                                          self.credit_card.blank?

    errors.add(:cvv, "can't be blank") if self.cvv == "0" || 
                                                          self.cvv.blank?

    self.expiration_date = DateTime.new(self.card_year.to_i, self.card_month.to_i).end_of_month

    errors.add(:expiration_date, "can't be in past") if self.expiration_date < Time.now

  end

  def save_with_multiple_sports(user_params)

    #save the object without params
    if self.save
      #get the high_school id to be linked with user
      high_school_id = self.high_school.id

      #create a users hash to be saved
      users_hash = create_users_hash(user_params, high_school_id)

      #create te users here from the hash
      create_users_from_users_hash(users_hash, high_school_id)
      subscription.update_attribute("organization_id", high_school_id)
    else
      return false
    end
  end

  def create_users_hash(user_params, high_school_id) 
    email_hash = {}   

    user_params.each do |x|
      sport = Sport.find(x[:sport_id])
      if email_hash.keys.include?(x[:email].squish!)
        email_hash[x[:email]][:user_sports_attributes] << { 
                    :sport_id => x[:sport_id],
                    :sport_name => sport.name,
                    :payer_id => self.id,
                    :organization_id => high_school_id,
                    :confirmed_at => Time.now,
                    :role => User::ROLES[:acc_owner] 
                  }
       else
         email_hash[x["email"]] = {
                        :first_name => x[:first_name], 
                        :last_name => x[:last_name], 
                        :role => x[:role],
                        :user_sports_attributes => [ {
                            :sport_id => x[:sport_id],
                            :sport_name => sport.name,
                            :payer_id => self.id,
                            :organization_id => high_school_id,
                            :confirmed_at => Time.now,
                            :role => User::ROLES[:acc_owner]
                            } ] 
                      }
       end
    
   end

    #For the reference - This is the kind of output we gonna get from the below code
    #{
    #  "sdga@gmail.com"=>{:first_name=>"sdfbs", :last_name=>"sddfvs", 
    #  :user_sports_attributes=>[{:sport_id=>"6", :role=> "acc_owner", :payer_id => "7"}, {:sport_id=>"1", :role=> "acc_owner", :payer_id => "7"}]}
    #}

   return email_hash
  end

  def create_users_from_users_hash(users_hash, high_school_id)
    users_hash.each do |k, v|
      user = User.find_by_email(k)
      if user.blank?
        User.create(v.merge(:email => k.dup.to_s, :high_school_id => high_school_id))
      else
        user.user_sports.create(v[:user_sports_attributes])
      end
    end
  end

  ###################################
  # protected methods and call backs
  ###################################
  protected

    def notify_admin_regarding_account_creation
      NotificationMailer.delay({ :run_at => 5.minutes.from_now }).new_account_information(self)
    end

  ##################
  # Private methods
  ##################
  private

    def set_university_to_user
      org = Organization::University.find_by_name(organization_name)
      if org.nil?
        errors.add(:base, "Please enter valid college/university")
      else
        @user.university_id = org.id
      end
    end

    def create_high_school_and_add_to_user
      high_school = build_high_school(:name => organization_name, :city => city, :state => state)
      if high_school.save
        @user.high_school = high_school
      end
    end

    def create_other_organization_and_add_to_user
      other_org = build_other_organization(:name => organization_name, :city => city, :state => state)
      if other_org.save
        @user.other_organization = other_org
      end
    end

    # Create account for Elite Edge and Foot Ball edge
    # create_account method sets the user, payer, user_sports first and 
    # then creates/saves the account.
    def create_account
      set_user
      set_payer
      set_user_sport
      save_account
    end

    # This method sets new user or existing user
    def set_user
      @form_user = User.new(:email => self.user_email, :first_name => self.user_first_name,
                           :last_name => self.user_last_name)
      @user = User.where(:email => self.user_email).first
      @new_user = false
      if @user.nil?
        @new_user = true
        @user = @form_user
      end
    end

    def set_payer
      self.set_payer_as_same_user(@user)
      @payer = self
    end

    def set_user_sport
      @existed_user_sport = nil
      @user_sport = nil
      sport = Sport.find_by_id(self.user_sport_id)
      @user_sport = UserSport.new(
            :sport_name => sport.try(:name), 
            :sport_id => sport.try(:id),
            :confirmed_at => Time.now,
            :role => User::ROLES[:acc_owner]
          )

      check_university_with_sport
      same_organization?(@user) if @new_user == false
    end

    def save_account
      if @payer.valid? && @payer.account_errors.blank? && @user.valid? && @user_sport.valid?
        if @payer.save && @payer.reload
          @user.new_sport_added = true if @new_user == false
          @user.save && @user.reload
          @payer.create_organization(@user) if @new_user == true
          @payer.subscription.update_attribute("organization_id", @user.reload.organization.id)
          @user_sport.user_id = @user.id
          @user_sport.payer_id = @payer.id
          @user_sport.organization_id = @user.organization.id
          @user_sport.save
          return true
        else
          self.account_errors = self.account_errors.presence || {}
          self.account_errors[:payer] = concat_error_message_arrays(self.account_errors[:payer], @payer.errors.full_messages)
          return false
        end
      else
        self.account_errors = self.account_errors.presence || {}
        self.account_errors[:user] = concat_error_message_arrays(self.account_errors[:user], @user.errors.full_messages)  if !@user.valid?
        self.account_errors[:user_sport] = concat_error_message_arrays(self.account_errors[:user_sport], @user_sport.errors.full_messages )  if @user_sport && !@user_sport.valid?
        self.account_errors[:payer] = concat_error_message_arrays(self.account_errors[:payer], @payer.errors.full_messages) if @payer.is_same_user == "no" && !@payer.valid?
        return false
      end
    end

    def check_university_with_sport
      arr_sport_users = UserSport.all(:include => [:user, :sport]).collect{ |us| [us.sport, us.user]}
      arr_sport_users.each do |arr|
        sport = arr[0]
        user = arr[1]
        if sport.present? && user.present?
          if sport.id == self.user_sport_id.try(:to_i) && user.organization.try(:name) == @payer.organization_name
            @payer.account_errors = self.account_errors.presence || {}
            @payer.account_errors[:payer] = concat_error_message_arrays(@payer.account_errors[:payer], ["Sport '#{sport.name}' is already assigned
                                             with this organization '#{@payer.organization_name}'"])
          end
        end
      end
    end

    def university_college_name
      if level == LEVELS[:college]
        org = Organization::University.find_by_name(organization_name)
        if org.nil?
          self.account_errors = self.account_errors.presence || {}
          self.account_errors[:payer] = concat_error_message_arrays(self.account_errors[:payer], ["Please enter valid college/university name"])
        end
      end
    end

    def basic_info
      self.account_errors = self.account_errors.presence || {}
      self.account_errors[:payer] = concat_error_message_arrays(self.account_errors[:payer], ["University/College/High School can't be blank"]) unless self.organization_name.present?
      self.account_errors[:payer] = concat_error_message_arrays(self.account_errors[:payer], ["City can't be blank"]) unless self.city.present?
      self.account_errors[:payer] = concat_error_message_arrays(self.account_errors[:payer], ["State can't be blank"]) unless self.state.present?
    end

    def same_organization?(user)
      if user.organization.name != self.organization_name
        self.account_errors = self.account_errors.presence || {}
        self.account_errors[:payer] = concat_error_message_arrays(self.account_errors[:payer], ["User is already registered with '#{user.organization.name}'"])
      end
    end

    def concat_error_message_arrays(old_array, new_array)
      old_array.nil? ? [] + new_array : old_array + new_array
    end

end
