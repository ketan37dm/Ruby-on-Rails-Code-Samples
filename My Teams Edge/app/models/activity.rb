class Activity < ActiveRecord::Base
  attr_accessible :user_id, :data_type, :data, :sport_id,
    :organization_id, :subvarsity_id, :user_ids, :resourceable, :user

  serialize :data, Hash
  serialize :user_ids, Array


  belongs_to :resourceable, :polymorphic => true
  belongs_to :user
  belongs_to :sport
  belongs_to :organization
  belongs_to :subvarsity
  has_many :feeds, :dependent => :destroy
end
