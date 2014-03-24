class Subscription < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :payer
  belongs_to :organization

  attr_accessible :last_4_digits, :user_id, :customer_id, :stripe_plan_id,
                  :expires_at


  def expired?
    expires_at < DateTime.now
  end

end
