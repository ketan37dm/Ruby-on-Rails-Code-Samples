class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id

  #######################  Associations  ####################
  belongs_to :user

  def provider_name
    provider.titleize
  end
end
