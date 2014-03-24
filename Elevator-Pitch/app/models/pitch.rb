class Pitch < ActiveRecord::Base
  require 'bitly'
  attr_accessible :description, :tags, :is_active, :user, :embed_code, :category_id

  acts_as_commentable


  #########################  Associations  #####################
  belongs_to :user
  belongs_to :category
  has_many :likes, :dependent => :destroy
  has_many :pitch_versions, :dependent => :destroy

  #########################  delegations  #####################
  delegate :company_present?, :email, :name, :add_link, :to => :user

  #########################  Validations  ######################
  validates :description , :presence => { :message => "^Your Pitch can't be blank" }
  validates :tags, :presence => {:message => "^Please tag your pitch"}
  validates :category, :presence => {:message => "^Please choose the pitch category"}

  ###################### Callbacks #########################
  before_create :set_identifier, :set_bitly_url
  before_validation :set_embed_code_info 
  before_save :create_version_if
  after_save :reindex_tags

  ##################### Constants ###########################
  PER_PAGE = 25
  SORT_TYPE_LIKE = "likes"
  SORT_TYPE_CREATED_AT = "created_at"
  EMBED_CODE_ERROR = "Invalid embed code. Please ensure you are entering the embed code and not URL."

  ##################### Scopes ###########################
  scope :sample, where(:sample => true)

  scope :active, where(:is_active => true)

  scope :include_user, includes(:user)

  scope :include_comments, includes(:comments)

  scope :include_likes, includes(:likes)

  scope :join_comments, joins(" LEFT JOIN comments ON pitches.id = comments.commentable_id AND comments.commentable_type = 'Pitch'")

  scope :join_likes, joins(" LEFT JOIN likes ON pitches.id = likes.pitch_id")

  scope :total_likes, select("pitches.*, COUNT(DISTINCT(likes.id)) AS total_likes, COUNT(DISTINCT(comments.id)) AS total_comments")

  scope :group_by_id, group("pitches.id")

  scope :sort_total_likes, order('total_likes DESC, pitches.created_at DESC')

  scope :sort_created_at, order('pitches.created_at DESC, total_likes DESC')
  
  scope :pitch_in, lambda { |ids| where("pitches.id in (?)", ids ) }

  scope :pitch_for, lambda {|category_id| where("pitches.category_id = ?", category_id)}
  ##################### Public ###########################

  class << self

    def sorted_pitches_according_to_total_likes
      tryhash = {}
      idset = []
      a = Pitch.where(:is_active => true).select("id, user_id")
      a.each { |r| tryhash.store( r.id, r.user.total_likes ) }
      tryhash.sort_by {|a,b| b}.reverse.each{|e| idset << e[0] }
      return idset
    end

    def list(hash = {:sort_by => "likes",:page => 1, :per_page => PER_PAGE})
      scope = total_likes.active.include_user.join_likes.join_comments.include_likes.group_by_id
      unless hash[:tags].blank?
        pitch_ids = $redis.smembers(hash[:tags].downcase.squish).collect{|i| i.to_i}
        scope = scope.pitch_in(pitch_ids) unless pitch_ids.blank?
      end
      unless hash[:category_id].blank?
        scope = scope.pitch_for(hash[:category_id])
      end
      scope = hash[:sort_by] == "created_at" ? scope.sort_created_at : scope.sort_total_likes
      scope.paginate(:page => hash[:page], :per_page => hash[:per_page])
    end
    
    def find_by_tags(tags = "")
      return [] if tags.blank?
      pitch_ids = []
      tags.split(",").each do |tag|
        pitch_ids = pitch_ids + $redis.smembers(tag.downcase.squish).collect{|i| i.to_i}
      end
      Pitch.find(pitch_ids.uniq)
    end

    def  sample_list
      sample
    end

    def total
      count
    end

    def rank(user)
      entries = select("pitches.user_id, COUNT(DISTINCT(likes.id)) total_likes").join_likes.sort_total_likes.group_by_id.all
      uniq_entries = entries.collect{|pitch| pitch['total_likes']}.uniq
      user_rank_map = {}

      entries.each do |entry|
        user_rank_map[entry['user_id']] = (uniq_entries.index(entry['total_likes']) + 1)
      end
      
      user_rank_map[user.id] || 0
    end
  end #end of the self block

  def set_me_false
    self.is_active = false
    self.save
  end

  def set_bitly_url()
    Bitly.use_api_version_3
    client = Bitly.new("idyllicsoftware", "R_b5a7ab5f7966ec86f0cde7f4a7e6b393")
    link = "http://#{SiteConfig.app_base_url}/pitches/#{self.identifier}"
    bitly = client.shorten(link) rescue link 
    self.bitly_url = bitly.short_url
  rescue Exception => e
    puts e.message
    puts e.backtrace
  end

  def comments_count
    (self.total_comments || comments.size) rescue comments.size
  end

  def likes_count
    self.likes.size
  end

  def liked?(user)
    self.likes.select{|like| like.user_id == user.id}.first rescue false
  end

  def my_pitch?(user)
    user && self.user_id == user.id
  end

  def video_exists?
    embed_url.present?
  end
  
  def tag_list(downcase = true)
    return [] if tags.blank?
    tags.split(",").collect{|tag| tag.downcase.squish}
  end

  def just_created?
    Time.now  - self.created_at < 90
  end
  

  ###################### Private ###########################
  private
  def set_identifier
    pass = Devise.friendly_token[0,20] 
    while !Pitch.where(:identifier => pass).first.blank?
      pass = Devise.friendly_token[0,20]
    end    
    self.identifier = Devise.friendly_token[0,20]
  end

  def create_version_if
    if !(self.new_record?) && self.description_changed?()
      version = self.pitch_versions.build(:description => self.changes['description'].first)
      version.save!
    end
  end

  def set_embed_code_info
    if self.embed_code.present?
      set_embed_url
      set_computer_width
      set_computer_height
      set_phone_width
      set_phone_height
    end
  rescue
      self.errors[:embed_code] << EMBED_CODE_ERROR if self.errors[:embed_code].blank?
  end

  def set_embed_url
    self.embed_url = self.embed_code.scan(/http\:\/\/.*?(?=")/i).first
  rescue
    self.errors[:embed_code] << EMBED_CODE_ERROR
  end

  def set_computer_width
    self.computer_width = 230
  end

  def set_computer_height
    self.computer_height = calculate_computer_height
  end

  def set_phone_width
    self.phone_width = 230
  end

  def set_phone_height
    self.phone_height = calculate_phone_height
  end

  def calculate_computer_height()
    width = parse_width
    height = parse_height
    calculate_height(self.computer_width, width, height)
  end

  def calculate_phone_height()
    width = parse_width
    height = parse_height
    calculate_height(self.phone_width, width, height)
  end

  def parse_height
    height_text = self.embed_code.scan(/(height=("|').*?"|'(?=\s))/i).first.first
    height_text.gsub(/[height]/, '').gsub(/["']/, '').gsub(/=/, '').strip.to_i
  end

  def parse_width
    width_text = self.embed_code.scan(/(width=("|').*?"|'(?=\s))/i).first.first
    width_text.gsub(/[width]/, '').gsub(/["']/, '').gsub(/=/, '').strip.to_i
  end

  def calculate_height(reference_width, width, height)
    ((reference_width * height)/width).to_i
  end
  
  def reindex_tags
    tag_list = Pitch.find(self.id).tag_list
    tag_list.each do |tag|
      $redis.srem(tag, self.id.to_s)
      $redis.del(tag) if $redis.smembers(tag).empty?
    end
    self.tag_list.each do |tag|
      $redis.sadd(tag, self.id.to_s)
    end
  rescue Exception => e
    puts e.backtrace
    true
  end
end
