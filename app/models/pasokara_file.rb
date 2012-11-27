# coding: utf-8
require "job/video_encoder"
require "ffmpeg_info"
require "ffmpeg_thumbnailer"

class PasokaraFile
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid

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
  field :encoding, :type => Boolean, :default => false
  field :tags, :type => Array, :default => []

  index({md5_hash: 1}, {unique: true})
  index({fullpath: 1}, {unique: true})
  index({tags: 1})

  mount_uploader :thumbnail, ThumbnailUploader

  belongs_to :directory, :index => true
  has_many :sing_logs

  validates_presence_of :name, :fullpath, :md5_hash

  after_save :save_tags

  searchable do
    text :name, :as => "name"
    string :name_str, :as => "name_str"
    string :tags, :multiple => true, :as => "tags"
    string :nico_name, :as => :nico_name
    integer :nico_view_counter, :as => "nico_view_counter"
    integer :nico_comment_num, :as => "nico_comment_num"
    integer :nico_mylist_counter, :as => "nico_mylist_counter"
    text :nico_description, :as => "nico_description"
    date :nico_post, :as => "nico_post"
    integer :duration, :as => "duration"
  end

  SORT_OPTIONS = [
    ["名前順", "name"],
    ["再生が多い順", "view_count"],
    ["再生が少い順", "view_count_r"],
    ["投稿が新しい順", "post_new"],
    ["投稿が古い順", "post_old"],
    ["マイリスが多い順", "mylist_count"],
  ]

  VIDEO_PATH = "/video"
  PREVIEW_PATH = "/pasokaras/preview"
  MOVIE_REGEXP = /(mpe?g|avi|flv|ogm|mkv|mp4|wmv|mov|rmvb|asf|webm|f4v|m4v)$/i

  paginates_per 50

  class << self
    def saved_file?(fullpath)
      !!(only(:fullpath).where(:fullpath => fullpath).first)
    end

    def load_file(path, parent_dir = nil)
      return nil unless path =~ MOVIE_REGEXP
      return nil if PasokaraFile.saved_file?(path)

      puts "#{path}を読み込み開始" unless Rails.env == "test"
      md5_hash = File.open(path, "rb:ASCII-8BIT") {|f| Digest::MD5.hexdigest(f.read(300 * 1024))}
      pasokara = PasokaraFile.find_or_initialize_by(:md5_hash => md5_hash)
      pasokara.attributes = {:name => File.basename(path), :fullpath => path, :md5_hash => md5_hash}
      pasokara.parse_info_file
      pasokara.update_thumbnail
      pasokara.directory = parent_dir
      if pasokara.new_record? or pasokara.changed?
        pasokara.save
      end
      pasokara
    end

    def load_dir(path)
      file_queue = []
      file_queue.extend(MonitorMixin)
      file_empty_cond = file_queue.new_cond
      dir_queue = []
      dir_queue.extend(MonitorMixin)
      dir_empty_cond = dir_queue.new_cond

      file_workers = []
      dir_workers = []

      2.times do
        file_workers << Thread.new do
          loop do
            deque_file(file_queue, file_empty_cond)
          end
        end
      end

      2.times do
        dir_workers << Thread.new do
          loop do
            deque_dir(dir_queue, dir_empty_cond, file_queue, file_empty_cond)
          end
        end
      end

      push_dir(path, nil, dir_queue, dir_empty_cond, file_queue, file_empty_cond)

      sleep 1

      loop do
        if dir_queue.empty? && dir_workers.all?(&:stop?)
          dir_workers.each(&:kill)
          break
        end
        sleep 1
      end

      loop do
        if file_queue.empty?
          file_workers.each(&:kill)
          break
        end
        sleep 1
      end

      Sunspot.commit
    end

    private
    def push_dir(dirpath, parent_dir, dir_queue, dir_empty_cond, file_queue, file_empty_cond)
      Dir.open(dirpath).entries.select {|e| e[0] != "."}.each do |filename|
        next_path = File.join(dirpath, filename)
        if File.directory?(next_path)
          dir_queue.synchronize do
            dir_queue.push([next_path, parent_dir])
            dir_empty_cond.signal
          end
        else
          file_queue.synchronize do
            file_queue.push([next_path, parent_dir])
            file_empty_cond.signal
          end
        end
      end
    end

    def deque_file(file_queue, file_empty_cond)
      file_queue.synchronize do
        file_empty_cond.wait_while { file_queue.empty? }
        filepath, parent_dir = file_queue.shift

        load_file(filepath, parent_dir)
      end
    end

    def deque_dir(dir_queue, dir_empty_cond, file_queue, file_empty_cond)
      dir_queue.synchronize do
        dir_empty_cond.wait_while { dir_queue.empty? }
        dirpath, parent_dir = dir_queue.shift

        directory = Directory.load_dir(dirpath, parent_dir)
        push_dir(dirpath, directory, dir_queue, dir_empty_cond, file_queue, file_empty_cond)
      end
    end
  end

  alias _name name
  def name(utf8 = true)
    utf8 ? _name : _name.encode("CP932")
  end

  # Sunspot dummy
  def name_str
    nil
  end

  def calc_md5
    File.open(fullpath, "rb:ASCII-8BIT") {|f| Digest::MD5.hexdigest(f.read(300 * 1024))}
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
    return "00:00" unless duration
    min = sprintf("%02d", duration / 60)
    sec = sprintf("%02d", duration % 60)
    "#{min}:#{sec}"
  end

  def nico_post_str
    nico_post.strftime("%Y/%m/%d") if nico_post
  end

  def nico_url
    "http://www.nicovideo.jp/watch/" + nico_name
  end

  def encode_prefix(type = :safari)
    "#{id}-#{type}"
  end

  def encode_filename(type = :safari)
    prefix = encode_prefix(type)
    case type
    when :safari
      prefix + ".mp4"
    when :webm
      prefix + ".webm"
    when :stream
      prefix + ".m3u8"
    end
  end

  def encode_filepath(type = :safari)
    VIDEO_PATH + "/" + encode_filename(type)
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

  def thumbnail_path
    fullpath.gsub(/#{Regexp.escape(File.extname(fullpath))}$/, ".jpg")
  end

  def exist_thumbnail?
    File.exist?(thumbnail_path)
  end

  def create_thumbnail
    if !exist_thumbnail? || File.size(thumbnail_path) == 0
      info = FFmpegInfo.getinfo(fullpath)
      duration = info[:duration] ? info[:duration] : 0
      ss = (info[:duration] / 10.0).round
      FFmpegThumbnailer.create(fullpath, ss)
    end
  end

  def update_thumbnail(force = false)
    if exist_thumbnail? && (force or thumbnail.size == 0)
      self.thumbnail = File.open(thumbnail_path)
      save
    else
      false
    end
  end

  def encoded?(type = :safari)
    !encoding && File.exist?(File.join(Rails.root, "public", encode_filepath(type)))
  end

  def tag_list
    @tag_list ||= TagList.new(tags)
    @tag_list
  end

  def do_encode(host, type = :safari)
    Resque.enqueue(Job::VideoEncoder, id, host, type)
  end

  def parse_info_file
    api_xml_file = fullpath.gsub(/\.[0-9a-zA-Z]+$/, "_info.xml")
    nico_player_info_file = fullpath.gsub(/\.[0-9a-zA-Z]+$/, ".txt")

    if File.exists?(api_xml_file)
      parser = NicoParser::ApiXmlParser.new
      info_file = api_xml_file
    elsif File.exists?(nico_player_info_file)
      parser = NicoParser::NicoPlayerParser.new
      info_file = nico_player_info_file
    end

    if parser
      self.attributes = parser.parse_info(info_file)
      self.tag_list.add parser.parse_tag(info_file)
    end
  end

  protected
  def save_tags
    if @tag_list
      self.class.skip_callback(:save, :after, :save_tags)
      new_tags = @tag_list - tags
      old_tags = tags - @tag_list

      old_tags.each do |t|
        tags.delete(t)
        self.save
        tag = Tag.find_or_create_by(name: t)
        if tag.size > 0
          tag.inc(:size, -1)
        end
      end

      new_tags.each do |t|
        tags << t
        self.save
        tag = Tag.find_or_create_by(name: t)
        tag.inc(:size, 1)
      end

      self.class.set_callback(:save, :after, :save_tags)
    end
  end
end
