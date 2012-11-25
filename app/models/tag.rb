class Tag
  include Mongoid::Document
  field :name, :type => String
  field :size, :type => Integer, :default => 0
  index({name: 1}, {unique: true})
  index({size: 1})

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
