class SingLog
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :pasokara_file
  belongs_to :user

  validates_associated :pasokara_file
  validates_presence_of :pasokara_file_id
end
