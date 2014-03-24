class PollQuestion < ActiveRecord::Base
  attr_accessible :active, :description

  has_many :poll_answers
  has_many :poll_results

  default_scope where(:active => true)

  scope :join_results, joins(" LEFT JOIN poll_results ON poll_results.poll_question_id = poll_questions.id")

  scope :not_in, lambda{|used_ids|where(["poll_questions.id NOT IN (:used_ids)", {:used_ids => used_ids}])}

  scope :randomize, order("RAND()")

  class << self

    def random(user)
      user_used_question_ids = PollResult.uniq_question_ids(user)
      not_in(user_used_question_ids.blank? ? [-1] : user_used_question_ids).randomize.first
    end
  end #end of the self block
end
