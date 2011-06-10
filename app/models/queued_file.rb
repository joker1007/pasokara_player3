class QueuedFile
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :pasokara_file, :index => true
  belongs_to :user, :index => true

  validates_associated :pasokara_file
  validates_presence_of :pasokara_file_id

  def self.enq(pasokara, user = nil)
    attrs = {pasokara_file_id: pasokara.id}
    attrs.merge({user: user.id}) if user
    QueuedFile.create(attrs)
  end

  def self.deq
    queue = QueuedFile.all.order_by("created_at desc").limit(1)[0]
    if queue and !(queue.pasokara_file.encoding)
      SingLog.create(pasokara_file_id: queue.pasokara_file_id, user: queue.user_id)
      queue.destroy
      queue
    else
      nil
    end
  end
end
