class Coach::UserUnitsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_account_owner!
  before_filter :load_user_organization

  def new_user_unit
    @user = User.find(params[:user_id])
    @user_units = @user.units(current_sport.id, @organization.id, current_user_sport.subvarsity_id)
    @disabled =  !current_user.custom_sports_units.where("custom_sports_units.unit_name not in  ( '#{User::ROLES[:coach]}', 
                                                '#{User::ROLES[:player]}', 
                                                '#{User::ROLES[:aux_user]}'
                                              )").where(:subvarsity_id => session[:subvarsity_id]).present?

  end

  def create_user_unit
  end

  def all_units

  end

  def existing_units_list
    @existing_units_list = CustomSportsUnit.units_for_sport(current_sport, current_user.organization, session[:subvarsity_id]) 

    @existing_units_list = @existing_units_list.search(params[:term])

    if params[:user_id]
      @user = User.find(params[:user_id])
      @user_units = @user.user_sports_units
      @existing_units_list -= @user_units.collect(&:custom_sports_unit)
    end

    if @existing_units_list.present?
      render json: @existing_units_list.compact.map { |unit| Hash[ id: unit.id,
                                                                   label: unit.unit_name,
                                                                   name:  unit.unit_name ] }
    else
      render json: Hash[name: 'No record']
    end
  end

  def add_user_to_unit
    if params[:user_id ].present? && params[:new_unit_id].present?
      @user = User.find(params[:user_id])
      @custom_sports_unit = current_user.custom_sports_units.find(params[:new_unit_id])
      @user_sports_unit = UserSportsUnit.create(user_id: @user.id, custom_sports_unit_id: @custom_sports_unit.id)
      @error = false
    else
      @error = true
      flash.now[:notice] = "Entered value is not existing unit"
    end
  end

  def remove_user_from_unit
    @user_sports_unit = UserSportsUnit.find(params[:unit_id] )
    @user =  @user_sports_unit.user
    custom_sports_unit_id = @user_sports_unit.custom_sports_unit_id
    @user_sports_unit.destroy
    @users_count = User.includes(:user_sports_units).
                   where("user_sports_units.custom_sports_unit_id = #{custom_sports_unit_id}").count
  end

end
