class CoursesController < ApplicationController

  #!before_filter :authenticate_coach_or_auxiliary_user!

  before_filter :load_user_organization

  def academics
    @user = User.find_by_id(params[:id])
    @courses = @user.courses
  end

  def show
    @course = Course.find_by_id(params[:id])
    @documents = @course.documents
    @previous_events = @course.course_events.order(:date)
  end

  def new
    @user = User.find_by_id(params[:user_id])
    @course = Course.new
  end

  def edit
    @course = Course.find_by_id(params[:id])
  end

  def create
    if params[:course][:weekdays].present?
      params[:course][:weekdays] = params[:course][:weekdays].values 
    end
    @course = Course.new(params[:course])
    @user = @course.user
    @courses = @user.courses
    if @course.valid? && @course.save
      flash.now.notice = "Course saved successfully."
    end
  end

  def add_document
    @course = Course.find_by_id(params[:id])
    @document = @course.documents.build if @course.present?
  end

  def save_document
    @course = Course.find_by_id(params[:id])
    @document = @course.documents.build(params[:document])
    if @document.valid? && @document.save
      flash.now.notice = "Document saved successfully"
    end
    @documents = @course.documents
  end

  def download
    @document = Document.find_by_id(params[:id])
    if @document.present?
      send_file @document.file.path, type: @document.file_content_type, filename: @document.file_file_name
    end
  end
  
  def add_course_event
    @course = Course.find_by_id(params[:id])
    @user = @course.user if @course.present?
    @course_event = @course.course_events.build if @course.present?
  end

  def create_course_event
    @course = Course.find_by_id(params[:course_id])
    @course_event = @course.course_events.build(params[:course_event])
    if @course_event.valid? && @course_event.save
      flash.now.notice = "Event saved successfully"
    end
    @previous_events = @course.course_events.order(:date)
  end

  def upcoming_events
    @user = User.find_by_id(params[:id])
    @todays_course_events = @user.todays_course_events
    @tomorrows_course_events = @user.tomorrows_course_events
    @overmorrows_course_events = @user.overmorrows_course_events
  end
end
