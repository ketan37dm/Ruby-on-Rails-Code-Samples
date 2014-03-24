class FollowsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_user
  before_filter :load_player
  before_filter :validate_xhr_request, only: [:create, :destroy]
  before_filter :authorized_request
  before_filter :set_request_from

  def create
    @follow = Follow.new(
                      :follower_id      => current_user.id,
                      :following_id     => @player.id,
                      :organization_id  => current_user.organization.id, 
                      :sport_id         => current_sport.id,
                      :subvarsity_id    => session[:subvarsity_id]
                    )
    @follow.save!
  end

  def destroy
    @follow = current_user.follows.where(
          :following_id => @player.id,
          :sport_id => current_sport.id,
          :subvarsity_id => session[:subvarsity_id]
        ).first

    @follow.delete
  end

  protected

    def authorized_request
      if current_user.allowed_follow_actions?(params[:user_id], current_sport, session[:subvarsity_id])
        return true
      else
        return false
      end
    end

    def load_player
      @player = User.find_by_id(params[:user_id])
    end

    def set_request_from
      @request_from = params[:type] unless params[:type].blank?
    end

end
