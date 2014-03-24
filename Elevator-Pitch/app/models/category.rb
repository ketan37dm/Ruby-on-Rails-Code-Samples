class Category < ActiveRecord::Base
  attr_accessible :title, :description
  has_many :pitches
end
