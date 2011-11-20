# coding: utf-8
class Directory
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  has_many :directories, :order => "name"
  has_many :pasokara_files, :order => "name"
  belongs_to :directory, :index => true

  validates_presence_of :name

  paginates_per 50

  def entities
    (directories + pasokara_files)
  end

  def self.load_dir(path, parent_dir = nil)
    puts "#{path}を読み込み開始" unless Rails.env == "test"
    directory = Directory.find_or_initialize_by(:name => File.basename(path))
    directory.directory = parent_dir
    directory.save if directory.new_record? || directory.changed?
    directory
  end
end
