class PitchesController < ApplicationController
  before_filter :authenticate_user!, :except => [:display, :remember]
  before_filter :check_created_pitch, :only => [:new, :create, :edit, :update, :show]
  before_filter :fetch_sample_pitches, :only => [:new, :create, :edit, :update]
  before_filter :load_categories, :only => [:edit, :update, :new, :create]

  def new
    @pitch = current_user.build_pitch()
  end

  def create
    @pitch = current_user.build_pitch(params[:pitch])
    set_pitch_status
    @pitch.save!
    if current_user.email.present?
      redirect_to(pitch_path)
    else
      redirect_to(edit_user_registration_path)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => "new"
  end

  def edit
    @pitch = current_user.pitch
  end

  def update
    @pitch = current_user.pitch
    @pitch.attributes = params[:pitch]
    set_pitch_status
    @pitch.save!
    if current_user.email.present?
      redirect_to(pitch_path)
    else
      redirect_to(edit_user_registration_path)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => "edit"
  end

  def show
    @pitch = current_user.pitch
    @comments = @pitch.comments
  end

  def remember
    session[:pitch_callback_url] = params[:pitch_callback_url]
    render :text => "Sucessfully remembered the pitch location!"
  end

  def display
    @pitch = Pitch.find_by_identifier(params[:identifier])
    @comments = @pitch.blank? ? [] : @pitch.comments
    render "show"
  end

  private
  def set_pitch_status
    @pitch.is_active = (params[:pitch_status] == "Publish" ? true : false)
  end

  def check_created_pitch
    if action_show? && !current_user.pitch_created?
      redirect_to new_pitch_path
    elsif action_edit_or_update? && !current_user.pitch_created?
      redirect_to new_pitch_path
      return false
    elsif action_new_or_create? && current_user.pitch_created?
      redirect_to edit_pitch_path
    end
  end

  def fetch_sample_pitches
    @sample_pitches = Pitch.sample_list
  end

  def load_categories
    @categories = Category.all
  end
end
