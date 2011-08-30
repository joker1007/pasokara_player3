# coding: utf-8
require "job/video_encoder"
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

  paginates_per 50

  def self.saved_file?(fullpath)
    only(:fullpath).where(:fullpath => fullpath).first
  end

  alias _name name
  def name(utf8 = true)
    utf8 ? _name : _name.encode("CP932")
  end

  # Sunspot dummy
  def name_str
    nil
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

  def tag_list
    @tag_list ||= TagList.new(tags)
    @tag_list
  end

  def do_encode(host)
    Resque.enqueue(Job::VideoEncoder, id, host)
  end

  def stream_path(host, force = false)
    if !force and mp4?
      path = movie_path
    else
      path = m3u8_path
      unless encoded?
        do_encode(host)
        sleep 1
      end
    end
    path
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
