class Tag
  include Mongoid::Document
  field :name, :type => String
  field :size, :type => Integer, :default => 0
  index :name, :unique => true
  index :size

  validates_presence_of :name

  paginates_per 50

  def count
    size
  end

  # sunspotのfacetとインターフェースを合わせるため
  def value
    name
  end
end
