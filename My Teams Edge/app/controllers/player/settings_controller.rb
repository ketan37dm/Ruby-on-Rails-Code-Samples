class Player::SettingsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_player!

  before_filter :load_user

  include ControllerHelpers::CommonMethods

  def update_personal_info
    @user.update_attributes(params[:user])
  end

  def add_course
    @course = @user.courses.build(params[:course])
    @course.save
  end

  def delete_course
    @course = Course.find(params[:course_id])
    @course.destroy
  end

end
