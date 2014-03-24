class Player::HomeController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_player!
  before_filter :load_user
  before_filter :home_page_events, only: [:index]

  def index
    @personal_info = @user.personal_info || @user.build_personal_info
    @course = @user.courses.build
    @courses = @user.courses.where("id is not null")
    @show_welcome_screen = show_welcome_screen?
  end

end
