class Document < ActiveRecord::Base
  #######################
  # constants
  #######################

  #######################
  # attribute accessors
  #######################

  #######################
  # attribute accessibles
  #######################
  attr_accessible :title, :info, :file
  
  ########################
  # Paper clip attributes
  ########################
  has_attached_file :file,
  :url  => "/system/documents/:id/:style/:basename.:extension",
  :path => "public/system/documents/:id/:style/:basename.:extension"

  #######################
  # Associations
  #######################
  belongs_to :course

  ##########################
  # accept nested attrubutes
  ##########################

  #######################
  # Validations
  #######################
  validates :title, presence: true
  validates :info, presence: true
  
  validates_attachment_presence :file
  validates_attachment_size :file, less_than: 2.megabytes, message: '^File size must be less than 2MB'
  #validates_attachment_content_type :file,
  #  content_type: %r{\.(docx|doc|pdf|document)$}i,
  #  message: '^File type must be in doc / docx / pdf '
  #validates_format_of :file, with: %r{\.(docx|doc|pdf)$}i, message: '^File type must be in doc / docx / pdf '

  #######################
  # Call backs
  #######################
  after_validation :check_file_content_type

  #######################
  # Class Methods
  #######################

  #######################
  #public methods
  #######################

  ###################################
  # protected methods and call backs
  ###################################
  protected

  def check_file_content_type  
    filetype = [".pdf", ".doc", ".docx", ".document"]
    if self.file_file_name.present?
      unless filetype.include?( File.extname(file_file_name) )
        self.errors.add(:file, "^File type must be in doc / docx / pdf")
        return false
      end
    end
  end

  #######################
  # Private methods
  #######################
  private

end
