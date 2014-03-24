class AuxiliaryUser::HomeController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_auxiliary_user!
  before_filter :home_page_events, only: [:index]


  def index
    @user = current_user
    @show_welcome_screen = show_welcome_screen?
  end

end
