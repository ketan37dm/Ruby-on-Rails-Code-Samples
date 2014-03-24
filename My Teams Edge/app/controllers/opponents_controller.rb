class OpponentsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authorized_associated_opponent

  def show
  end

  def create
    @new_opponent = Opponent.new(params[:opponent])
    @new_opponent.save
  end

  protected

  def authorized_associated_opponent
    #do something to make sure only relevant users are viewing the opponent show page
    if required_params?([:opponent_id])

      @organization = current_user.organization
      @sport = current_sport
      @opponent = @organization.opponents.where(id: params[:opponent_id]).first
      
      data_arr = [@opponent, @sport, @organization]
      return true if required_data?(data_arr) && @opponent.present?
      return redirect_to root_url
    else
      return redirect_to root_url
    end
  end

end
