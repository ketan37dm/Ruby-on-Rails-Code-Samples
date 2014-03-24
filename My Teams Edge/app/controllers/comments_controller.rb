class CommentsController < ApplicationController

  before_filter :authenticate_user!
  
  def create
    @comment = Comment.new(params[:comment].merge(:commentator_id => current_user.id))

    if @comment.save
      @event = @comment.commentable
    end
  end

end
