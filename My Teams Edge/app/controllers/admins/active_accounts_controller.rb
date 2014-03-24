class Admins::ActiveAccountsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @subscriptions = Subscription.includes(:organization).where("expires_at >= ?", DateTime.now)
    @active_organizations = @subscriptions.collect(&:organization).try(:uniq)
    @current_active_organization = (Organization.find(params[:organization_id]) rescue nil) || @active_organizations.first
    @active_sports = @current_active_organization.active_sports rescue []
    @show_details = @active_sports.count == 1
    @active_sport = @active_sports.first rescue nil
    @package_details = @active_sport.package_details if @active_sport.present?
  end

  def show_account
    @active_sport = UserSport.find(params[:user_sport_id])
    @subscriptions = Subscription.includes(:organization).where("expires_at >= ?", DateTime.now)
    @active_organizations = @subscriptions.collect(&:organization).try(:uniq)
    @current_active_organization = (Organization.find(@active_sport.organization_id) rescue nil) || @active_organizations.first
    @active_sports = @current_active_organization.active_sports rescue []
    @show_details = true
    @package_details = @active_sport.package_details if @active_sport.present?
    render :index
  end

end
