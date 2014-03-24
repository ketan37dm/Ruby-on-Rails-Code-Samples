class Schedules::Apps::VideoScoutsController < Schedules::Apps::AppsApplicationController

  before_filter :get_opponent, :only => [:index]

  def index
  end

end
