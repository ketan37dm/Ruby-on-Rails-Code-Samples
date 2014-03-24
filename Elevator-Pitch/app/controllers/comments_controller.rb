class CommentsController < ApplicationController
  include ActionView::Helpers::TextHelper
  
  before_filter :authenticate_user!, :populate_pitch

  def create
    @comment_instance = @pitch.comments.new
    @comment_instance.user_id = current_user.id
    @comment_instance.comment = params[:comment][:comment]
    
    if @comment_instance.save
      respond_to do |format|
        format.json {render :json => {:comment => simple_format(@comment_instance.comment), :comment_timestamp => @comment_instance.created_at.strftime(COMMENT_TIME_FORMAT), :commentator_name => @comment_instance.user.name}.to_json}
        format.html {render :text => "Sucessfully created a comment"}
      end
    else
      respond_to do |format|
        status = :unprocessable_entity
        format.json {render :json => {:error => @comment_instance.errors.full_messages.first}.to_json, :status => status}
        format.html {render :text => "Erorr while creating the comment", :status => status}
      end
    end
  end
end
