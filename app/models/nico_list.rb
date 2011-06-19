class NicoList
  include Mongoid::Document
  include Mongoid::Timestamps
  field :url, :type => String
  field :download, :type => Boolean, :default => true

  validates_presence_of :url
  validates_uniqueness_of :url
end
