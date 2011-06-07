class PasokaraFile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :fullpath, :type => String
  field :md5_hash, :type => String
  field :nico_name, :type => String
  field :nico_post, :type => Time
  field :nico_view_counter, :type => Integer
  field :nico_comment_num, :type => Integer
  field :nico_mylist_counter, :type => Integer
  field :duration, :type => Integer
  field :nico_description, :type => String
  field :encoding, :type => Boolean

  belongs_to :directory
  has_many :sing_logs

  validates_presence_of :name, :fullpath, :md5_hash

  VIDEO_PATH = "/video"
  PREVIEW_PATH = "/pasokara/preview"

  alias _name name
  def name(utf8 = true)
    utf8 ? _name : _name.encode("CP932")
  end

  def extname
    File.extname(fullpath)
  end

  def movie_path
    File.join(VIDEO_PATH, "#{id}#{extname}")
  end

  def preview_path
    File.join(PREVIEW_PATH, id.to_s)
  end

  def duration_str
    min = sprintf("%02d", duration / 60)
    sec = sprintf("%02d", duration % 60)
    "#{min}:#{sec}"
  end

  def nico_post_str
    nico_post.strftime("%Y/%m/%d")
  end

  def nico_url
    "http://www.nicovideo.jp/watch/" + nico_name
  end

  def stream_prefix
    "#{id}-stream"
  end

  def m3u8_filename
    "#{stream_prefix}.m3u8"
  end

  def m3u8_path
    File.join(VIDEO_PATH, m3u8_filename)
  end

  def exist?
    File.exist?(fullpath)
  end

  def mp4?
    exist? && extname == ".mp4"
  end

  def flv?
    exist? && extname == ".flv"
  end

  def encoded?
    File.exist?(File.join(Rails.root, "public", m3u8_path))
  end
end
