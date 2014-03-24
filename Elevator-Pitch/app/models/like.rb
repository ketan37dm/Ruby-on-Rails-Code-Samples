class Like < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :user
end
