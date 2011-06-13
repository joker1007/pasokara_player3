class SingLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :user_name

  index :created_at

  belongs_to :pasokara_file, :index => true
  belongs_to :user, :index => true

  validates_associated :pasokara_file
  validates_presence_of :name
  validates_presence_of :pasokara_file_id

  paginates_per 50
end
