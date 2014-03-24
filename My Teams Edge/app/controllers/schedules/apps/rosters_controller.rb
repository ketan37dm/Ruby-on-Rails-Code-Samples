class Schedules::Apps::RostersController < Schedules::Apps::AppsApplicationController
  
  before_filter :get_opponent, :only => [:index]

  def index
  end

end
