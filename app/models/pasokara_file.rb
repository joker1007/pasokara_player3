# coding: utf-8
require "job/video_encoder"
require "ffmpeg_info"
require "ffmpeg_thumbnailer"
require "carrierwave/orm/mongoid"
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

  index :md5_hash, :unique => true
  index :fullpath, :unique => true
  index :tags

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

  def self.saved_file?(fullpath)
    only(:fullpath).where(:fullpath => fullpath).first
  end

  def self.load_dir(path)
    file_queue = Queue.new
    dir_queue = Queue.new

    Dir.open(path).entries.select {|e| e[0] != "."}.each do |filename|
      next_path = File.join(path, filename)
      if File.directory?(next_path)
        dir_queue.enq([next_path, nil])
      else
        file_queue.enq([next_path, nil])
      end
    end

    file_workers = []
    dir_workers = []

    2.times do
      file_workers << Thread.new do
        loop do
          filepath, parent_dir = file_queue.deq

          if filepath =~ MOVIE_REGEXP
            unless PasokaraFile.saved_file?(filepath)
              puts "#{filepath}を読み込み開始" unless Rails.env == "test"
              md5_hash = File.open(filepath, "rb:ASCII-8BIT") {|f| Digest::MD5.hexdigest(f.read(300 * 1024))}
              pasokara = PasokaraFile.find_or_initialize_by(:md5_hash => md5_hash)
              pasokara.attributes = {:name => File.basename(filepath), :fullpath => filepath, :md5_hash => md5_hash}
              pasokara.parse_info_file
              pasokara.update_thumbnail
              pasokara.directory = parent_dir
              if pasokara.new_record?
                pasokara.save ? pasokara.id : nil
              else
                pasokara.save if pasokara.changed?
              end
            end
          end
        end
      end
    end

    2.times do
      dir_workers << Thread.new do
        loop do
          dirpath, parent_dir = dir_queue.deq
          puts "#{dirpath}を読み込み開始" unless Rails.env == "test"
          directory = Directory.find_or_initialize_by(:name => File.basename(dirpath))
          directory.directory = parent_dir
          directory.save if directory.new_record? || directory.changed?

          Dir.open(dirpath).entries.select {|e| e[0] != "."}.each do |filename|
            next_path = File.join(dirpath, filename)
            if File.directory?(next_path)
              dir_queue.enq([next_path, directory])
            else
              file_queue.enq([next_path, directory])
            end
          end
        end
      end
    end

    loop do
      if file_queue.empty? && dir_queue.empty? && dir_queue.num_waiting == 2
        sleep 1
        if file_queue.empty? && dir_queue.empty? && dir_queue.num_waiting == 2
          Sunspot.commit
          return
        end
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
    File.exist?(fullpath.gsub(/#{Regexp.escape(File.extname(fullpath))}$/, ".jpg"))
  end

  def create_thumbnail
    info = FFmpegInfo.getinfo(fullpath)
    duration = info[:duration] ? info[:duration] : 0
    ss = (info[:duration] / 10.0).round
    FFmpegThumbnailer.create(fullpath, ss)
  end

  def update_thumbnail(force = false)
    if exist_thumbnail? && (force or self.thumbnail.size == 0)
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
