class PersonalInfo < ActiveRecord::Base

  attr_accessor :positions

  attr_accessible :jersey_number, :height, :weight, :school_year, :positions

  belongs_to :user, :conditions => "role = #{User::ROLES[:player]}"

  validates :jersey_number, numericality: { only_integer: true }, :allow_blank => true
  validates :height, numericality: { only_integer: true }, :allow_blank => true
  validates :weight, numericality: { only_integer: true }, :allow_blank => true
  validates :school_year, numericality: { only_integer: true }, :allow_blank => true


  after_save :add_positions, :if => Proc.new { |pi| pi.positions.present? }

  private

  def add_positions
    positions.each do |position|
      position.values.each do |value|
        if value.present?
          record = UserSportsUnit.where( custom_sports_unit_id: value.to_i, user_id: self.user_id)
          if record.empty?
            UserSportsUnit.create( custom_sports_unit_id: value.to_i, user_id: self.user_id)
          end
        end
      end
    end
  end

end
