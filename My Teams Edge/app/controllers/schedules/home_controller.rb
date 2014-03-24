class Schedules::HomeController < ApplicationController

  before_filter :authenticate_user!
  #before_filter :authenticate_acc_owner_or_coach!

  #before_filter :load_user_organization

  def index
    @new_opponent = Opponent.new
    @upcoming_opponents = current_user.upcoming_opponents(current_sport.id, session[:subvarsity_id])
  end

  def previous_opponents
    @previous_opponents = current_user.previous_opponents(current_sport.id, session[:subvarsity_id])
  end

  def add_opponent
    @new_opponent = Opponent.new(params[:opponent])
    
    if @new_opponent.save
      get_upcoming_opponents
    end
  end

  def sync_opponents
    @opponent = Opponent.find_by_id(params[:id])
    create_opponents_array
    get_upcoming_opponents
  end

  def show_opponent
    @opponent = Opponent.find_by_id(params[:id])
  end

  def destroy_opponent
    Opponent.find_by_id(params[:id]).try(:destroy)
    return redirect_to schedules_root_path
  end

  def update_opponent
    @opponent = Opponent.find_by_id(params[:id])
    @opponent.update_attributes(params[:opponent])
  end

  private

    def get_upcoming_opponents
      @upcoming_opponents = current_user.upcoming_opponents(current_sport.id, session[:subvarsity_id])
    end

    def create_opponents_array
      params[:opponents].each do |opponent_hash|
        opponent = @opponent.dup
        opponent.location = opponent_hash[:location]
        opponent.event_at = opponent_hash[:event_at]
        opponent.save
      end
    end

end
