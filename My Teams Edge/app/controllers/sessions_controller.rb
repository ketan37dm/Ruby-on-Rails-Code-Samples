class SessionsController < Devise::SessionsController

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    set_current_sport(resource.user_sports.first.sport.id) if resource.sports.present?
    session[:subvarsity_id] = resource.user_sports.first.subvarsity_id
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

  def destroy
    session[:sport_id] = nil
    session[:subvarsity_id] = nil
    super
  end
end
