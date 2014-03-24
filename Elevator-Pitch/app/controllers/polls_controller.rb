class PollsController < ApplicationController
  before_filter :authenticate_user!
    
  def create
    @poll_result = current_user.poll_results.build(params[:poll_result])
    @poll_result.save!

    respond_to do |format|
      format.json{render :json => {:message => "Successfully registered your opinion"}}
      format.html{render :text => "Successfully submitted the poll"}
    end
  end
end
