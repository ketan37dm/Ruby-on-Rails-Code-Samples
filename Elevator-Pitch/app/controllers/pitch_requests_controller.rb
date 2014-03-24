class PitchRequestsController < ApplicationController
  def new
  	@categories = Category.all
    @pitch_request = PitchRequest.new(:category_id => Category.first.id)
  end

  def create 
    @pitch_request = PitchRequest.new(params[:pitch_request],:user => current_user)
    @pitch_request.save!
      redirect_to root_path, :flash => { :success => "Alriight. We'll contact you shortly regarding your pitch. Till then look at how others are pitching themselves." }
  rescue ActiveRecord::RecordInvalid
  	@categories = Category.all
    render :action => "new"
  end
end
