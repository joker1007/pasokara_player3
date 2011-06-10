class SingLog
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :pasokara_file, :index => true
  belongs_to :user, :index => true

  validates_associated :pasokara_file
  validates_presence_of :pasokara_file_id
end
