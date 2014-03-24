class PollAnswer < ActiveRecord::Base
  attr_accessible :description, :poll_question_id

  belongs_to :poll_question
  has_many :poll_results
end
