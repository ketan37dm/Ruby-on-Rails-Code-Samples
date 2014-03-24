class ApplicationController < ActionController::Base
  
  layout :determine_layout, :if => :not_xhr?
  
  protect_from_forgery
  
  helper_method :current_sport, :default_url, :current_role, :current_user_sport, :current_subvarsity?



  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      admins_root_path
    else
      default_url(resource)
    end
  end


  #creates the new subscription
  def create_new_sign_up
    #return if there is no plan id
    return redirect_to :back, :alert => "No package selected" if package_blank?
    create_elite_edge and return if package?("elite_edge")
    create_football_edge and return if package?("football_edge")
    @payer = Payer.new(params[:payer])
    @package = params[:package]
    if @payer.save_with_multiple_sports(params[:users_attributes])
      flash[:notice] = "Account Created Successfully! An email has been sent with details."
      return redirect_to current_admin ? add_admins_accounts_path : root_url
    else
      flash[:notice] = "Account creation failed !! There was some error !"
      render current_admin ? "add" : "new"
    end
  end

  ####################
  ## Protected Methods
  ####################
  protected

    def validate_xhr_request
      unless request.xhr?
        flash[:notice] = "Invalid request"
        return redirect_to root_url
      end
    end

    def show_welcome_screen?
      return true #TODO- delete this line once testing on staging is finised
      if Rails.env.development?
        return true
      end
      if @user.identifier
        @user.update_attribute(:identifier, nil)
      else
        return false
      end
    end


    def required_params?(params_keys = [])
      params_keys.each { |key| return false if params[key].blank? }
      return true
    end

    def required_data?(data = [])
      data.each {|value| return false if value.blank? }
      return true
    end

    def load_user
      @user ||= current_user
    end

    def current_role
      @current_role ||= current_user.role_in_sport(current_sport, session[:subvarsity_id])
    end

    def home_page_events
      @todays_events = current_user.events_due_on(Date.today, current_sport) rescue []
      @tomorrows_events = current_user.events_due_on(Date.tomorrow, current_sport) rescue []
      @overmorrows_events = current_user.events_due_on(Date.tomorrow + 1, current_sport) rescue [] # Day after tomorrow's events
    end

    def determine_layout
      layout_name = ""
      if request.url =~ /admins/
        layout_name = "admin"
      else
        layout_name = "application"
      end
      return layout_name
    end

    def symbolize_update_on_for_user
      params[:user][:update_on] = params[:user][:update_on].to_sym if params[:user].present? &&
        params[:user][:update_on].present?             
    end

    def load_user_organization
      @organization = current_user.organization
    end

    def package_blank?
      params[:package].blank? || !User::STRIPE_PLAN_IDS.include?(params[:package])
    end

    def package?(package)
      params[:package] == package
    end

    def not_xhr?
      !request.xhr?
    end

  ####################
  ## Private Methods
  ####################
  private

    def set_current_sport(sport_id)
      session[:sport_id] = sport_id
    end

    def current_sport
      @sport = Sport.find_by_id(session[:sport_id]) || current_user.sports.try(:first)
    end

    def redirect_to_current_user_default_url
      redirect_to default_url(current_user) if current_user
    end

    def default_url(current_user)
      return player_home_index_path if current_user.player?(current_sport, session[:subvarsity_id])
      return coach_home_index_path if current_user.account_owner_or_coach?(current_sport, session[:subvarsity_id])
      return auxiliary_user_home_index_path if current_user.auxiliary_user?(current_sport, session[:subvarsity_id])
    end

    def authenticate_account_owner!
      if current_user && !(current_user.account_owner?(current_sport, session[:subvarsity_id]) || current_user.coach?(current_sport, session[:subvarsity_id]))
        flash[:alert] = "Permission denied!!!"
        redirect_to_current_user_default_url 
      end
    end

    def authenticate_coach_or_auxiliary_user!
      if current_sport && !(current_user.account_owner?(current_sport, session[:subvarsity_id]) || current_sport.auxiliary_user?(current_sport, session[:subvarsity_id]))
        flash[:alert] = "Permission denied!!!"
        redirect_to_current_user_default_url
      end
    end

    def authenticate_coach!
      if current_user && !current_user.coach?(current_sport, session[:subvarsity_id])
        flash[:alert] = "Permission denied!!!"
        redirect_to_current_user_default_url
      end
    end

    def authenticate_player!
      if current_user && !current_user.player?(current_sport, session[:subvarsity_id])
        flash[:alert] = "Permission denied!!!"
        redirect_to_current_user_default_url
      end
    end

    def authenticate_auxiliary_user!
      if current_user && !current_user.auxiliary_user?(current_sport, session[:subvarsity_id])
        flash[:alert] = "Permission denied!!!"
        redirect_to_current_user_default_url
      end
    end

    def authenticate_acc_owner_or_coach!
      if current_user && !current_user.account_owner_or_coach?(current_sport, session[:subvarsity_id])
        flash[:alert] = "Permission denied!!!"
        redirect_to_current_user_default_url
      end
    end

    #TODO - change the querry on this method after adding organization id to the user_sports
    def current_subvarsity?
      current_user_sport.subvarsity_id.present?
    end

    def current_user_sport
      query_string = "sport_id = #{current_sport.id}"
      
      if session[:subvarsity_id].present?
        query_string += " and subvarsity_id = #{session[:subvarsity_id]}"
      else
        query_string += " and subvarsity_id is null"
      end
      current_user.user_sports.where(query_string).first
    end

end
