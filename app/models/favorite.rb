class Favorite
  include Mongoid::Document

  belongs_to :user
  has_and_belongs_to_many :pasokara_files
end
