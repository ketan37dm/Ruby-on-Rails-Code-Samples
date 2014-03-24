class PollResult < ActiveRecord::Base
  attr_accessible :poll_question_id, :poll_answer_id, :user_id

  belongs_to :poll_question
  belongs_to :poll_answer
  belongs_to :user

  scope :for_user_id, lambda{|user_id|where(:user_id => user_id)}

  class << self
    def uniq_question_ids(user)
      for_user_id(user.id).select(:poll_question_id).uniq
    end 
  end #end of the self block
end
