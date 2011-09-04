class QueuedFile
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

  def self.enq(pasokara, user = nil)
    attrs = {name:pasokara.name, pasokara_file_id: pasokara.id}
    attrs.merge!({user_name: user.nickname, user: user.id}) if user
    QueuedFile.create(attrs)
  end

  def self.deq
    queue = QueuedFile.order_by("created_at desc").first
    if queue and !(queue.pasokara_file.encoding)
      SingLog.create(name:queue.name, user_name:queue.user_name, pasokara_file_id: queue.pasokara_file_id, user: queue.user_id)
      queue
    else
      nil
    end
  end
end
