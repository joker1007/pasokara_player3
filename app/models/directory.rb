class Directory
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  has_many :directories, :order => "name"
  has_many :pasokara_files, :order => "name"
  belongs_to :directory, :index => true

  validates_presence_of :name

  paginates_per 50

  def entities
    (directories + pasokara_files)
  end
end
