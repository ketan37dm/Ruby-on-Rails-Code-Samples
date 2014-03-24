class WelcomeController < ApplicationController

  before_filter :redirect_to_current_user_default_url, except: [:autocomplete_university_name, :update_email, :autocomplete_high_school_name]

  autocomplete :university, :name, :full => true, :extra_data => [ :city, :state ]

  autocomplete :high_school, :name, :full => true, :extra_data => [ :city, :state ]

  def login_with_sport
    user = User.find_by_identifier(params[:identifier])
    if sign_in(:user, user)
      sport = user.user_sports.last.sport rescue nil
      set_current_sport(sport.id) if sport.present?
      session[:subvarsity_id] = user.user_sports.last.subvarsity_id
      redirect_to_current_user_default_url
    else
      new_user_session_path
    end
  end

  def update_email
    user = User.find(params[:id])

    if user && user.identifier == params[:identifier]
      user.email = user.new_email
      user.identifier = nil
      user.new_email = nil
      user.save(:validate => false)
      flash[:notice] = "Email changed successfully"
    end

    if current_user
      redirect_to account_change_email_path
    else
      redirect_to new_user_session_path
    end
  end

  private

  # Filtering universities from autocomplete
  # Don't show current_user university in the list if he has any
  def get_autocomplete_items(parameters)
    items = super(parameters)
    if current_user
      items = items - [current_user.organization] if current_user.organization.present?
    end
    return items
  end


end
