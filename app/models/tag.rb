class Tag
  include Mongoid::Document
  field :name, :type => String
  index :name, :unique => true

  has_and_belongs_to_many :pasokara_files, :index => true

  validates_presence_of :name
end
