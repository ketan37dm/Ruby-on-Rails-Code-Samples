class Schedules::Apps::AppsApplicationController < ApplicationController

  before_filter :authenticate_user!
  
  helper_method :current_opponent
    

  protected
    
    #this methos to be used only in schedules apps as for now
    def current_opponent
      Opponent.find_by_id(session[:opponent_id])
    end

  private
    
    def get_opponent
      @opponent = Opponent.find_by_id(params[:opponent])
      session[:opponent_id] = @opponent.id
      return redirect_to schedules_root_url if @opponent.blank?
    end
    
end
