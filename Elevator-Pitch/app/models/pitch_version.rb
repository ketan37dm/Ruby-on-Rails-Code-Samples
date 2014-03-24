class PitchVersion < ActiveRecord::Base
  belongs_to :pitch

  attr_accessible :description, :pitch_id

  validates :pitch_id, :presence => true
end
