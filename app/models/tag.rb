class Tag
  include Mongoid::Document
  field :name, :type => String

  has_and_belongs_to_many :pasokara_files

  validates_presence_of :name
end
