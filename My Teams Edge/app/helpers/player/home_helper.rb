module Player::HomeHelper

  def positions_options
    current_user.sport_units_for(current_sport, current_user_sport.subvarsity_id).map { |position| [position.unit_name, position.id] } if current_user
  end

end
