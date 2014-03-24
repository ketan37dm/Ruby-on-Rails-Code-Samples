class PayersController < ApplicationController
  
  def new
    return redirect_to pricing_path if package_blank?
    @package = params[:package]
    @payer = Payer.new
  end

  def create
    #find this in application controller
    create_new_sign_up
  end

  def validate_highschool_params
    @high_school = HighSchool.new(params[:high_school])
    @high_school.valid?
  end

  def validate_user_params
    @user = User.find_by_email(params[:user][:email])
    if @user.blank?
      @user = User.new(params[:user])
      @user.valid?
    else
      if @user.organization != HighSchool.find_by_name(params[:high_school_name])
        @user.errors.add(:high_school_id, "^Already registed with another organization")
      else
        @user_sports = @user.user_sports.where([
            "sport_id = ? and subvarsity_id is null",
            params[:user][:sport_id].to_i
          ]).first
        if @user_sports.present?
          @user.errors.add(:sport_id, "^This sport has already been assigned")
        end
      end
    end
    @sport = Sport.find_by_id(params[:user][:sport_id])

    @user_counter = params[:user_counter] unless params[:user_counter].blank?
  end

  def validate_payer_params
    @payer = Payer.new(params[:payer])
    @payer.valid_with_credit_card?
  end

  private

  def create_elite_edge
    @payer = Payer.new(params[:payer])
    @package = @payer.update_on = params[:package]
    if @payer.create_elite_edge
      flash[:notice] = "Account Created Successfully! An email has been sent with details."
      return redirect_to root_url
    else
      render "new"
    end
  end

  def create_football_edge
    @payer = Payer.new(params[:payer])
    @package = @payer.update_on = params[:package]
    if @payer.create_football_edge
      flash[:notice] = "Account Created Successfully! An email has been sent with details."
      return redirect_to root_url
    else
      render "new"
    end
  end

end
