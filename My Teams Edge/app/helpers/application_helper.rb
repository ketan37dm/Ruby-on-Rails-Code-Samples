module ApplicationHelper


  def get_quote_for_today
    @todays_quote = Quote.quote_for_today
  end

  def is_link_active(con, act)
    if ( con == params[:controller] && act == params[:action] )
      return "active active-tab" 
    else
      return false 
    end
  end

  def display_error_messages(errors, detail = false)
    html_data = ""
    errors.each do|obj, messages|
      messages.uniq.each do |message|
        message = "#{obj.to_s.try(:titleize) } #{message}" if detail == true
        html_data += content_tag(:li, "#{message}")
      end
    end
    html_data.html_safe
  end

  def logo_path
    if user_signed_in?
      return player_home_index_path if current_user.player?(current_sport, current_user_sport.subvarsity_id)
      return coach_home_index_path if current_user.account_owner_or_coach?(current_sport, current_user_sport.subvarsity_id)
      return auxiliary_user_home_index_path if current_user.auxiliary_user?(current_sport, current_user_sport.subvarsity_id)
    else
      "/"
    end
  end

  def current_account_tab(tab)
    return "selected" if tab.include?(action_name)
  end


  def current_account_tab_content(tab)
    return "active" if tab.include?(action_name)
  end

  def set_active_class(controller)
    return "active" if params[:controller] =~ /(coach|auxiliary_user|player)\/#{controller}/
    return "active" if controller != "home" && params[:controller] =~ /#{controller}/
    return ""
  end

  def follow_unfollow(user)
    if current_user.follows.where(following_id: user.id, sport_id: current_sport.id, subvarsity_id: current_user_sport.subvarsity_id).count > 0
      link_to("Unfollow", follows_path(user_id: user.id), method: :delete, remote: true, class: "unfollow-button follow-unfollow-button" )
    else
      link_to("Follow", follows_path(user_id: user.id), remote: true, class: "follow-unfollow-button")
    end
  end

  def follow_unfollow_button_class(user)
    ( current_user.follows.where(following_id: user.id, sport_id: current_sport.id, subvarsity_id: current_user_sport.subvarsity_id).count > 0 ) ? "btn btn-info" : "btn"
  end

  def user_update_photo_with_contact(user, sport)
    return update_photo_with_contact_auxiliary_user_settings_path if user.auxiliary_user?(sport, current_user_sport.subvarsity_id)
    return update_photo_with_contact_player_settings_path if user.player?(sport, current_user_sport.subvarsity_id)
    return update_photo_with_contact_coach_home_index_path if user.account_owner_or_coach?(sport, current_user_sport.subvarsity_id)
  end

  def admin_navbar_active_class(con)
    return "active" if ( con == params[:controller] )
  end

  def get_admin_body_class(con, act)
    return "admin"  if con == "admins/home" && act == "index"
  end

  def show_links_to_manager?
    current_user.account_owner?(current_sport, current_user_sport.subvarsity_id) && 
    @organization.is_a?(HighSchool) && 
    !current_subvarsity?
  end

  def option_selected?(original_ele, manupulated_ele)
    "selected=selected" if original_ele.try(:to_s) == manupulated_ele.try(:to_s)
  end

  def contact_reason
    [
      ["Reason For Contacting", ""],
      ["Reason 1","Reason 1"],
      ["Reason 2","Reason 2"],
      ["Reason 3","Reason 3"]
    ]
  end

  def personnel_allow_edit?(user)
    (!user.account_owner?(current_sport, current_user_sport.subvarsity_id) && 
    current_user != user &&
    user.parent?(current_sport.id, current_user.id, current_user_sport.subvarsity_id)) ||
    (current_user.account_owner?(current_sport, current_user_sport.subvarsity_id) && 
    current_user != user)
  end

  def contacts_user_details_active_tab(con, act)  
    return "active" if ( con == params[:controller] && act == params[:action] )
  end

  def get_autocomplete_path(organization)
    if organization.is_a?(HighSchool)
      autocomplete_high_school_name_welcome_index_path
    else
      autocomplete_university_name_welcome_index_path
    end
    
  end
  
end
