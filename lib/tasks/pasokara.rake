# _*_ coding: utf-8 _*_
require File.dirname(__FILE__) + '/../../config/environment'

namespace :niconico do
  desc 'download nicokara movie'
  task :download do
    downloader = Util::NicoDownloader.new
    setting = YAML.load_file(File.dirname(__FILE__) + '/../../config/pasokara_player.yml')
    setting["url_list"].each do |url|
      downloader.rss_download(url, setting["download_dir"])
      sleep 15
    end
    Sunspot.commit
  end
end

namespace :pasokara do
  desc 'no file directory delete'
  task :delete_dir do
    Directory.find(:all).each do |d|
      if d.pasokara_files.empty? && d.directories.empty?
        d.destroy
        puts "#{d.id} is deleted"
      end
    end
  end

  desc 'load data from root_dir'
  task :load do
    setting = YAML.load_file(File.dirname(__FILE__) + '/../../config/pasokara_player.yml')
    PasokaraPlayer.load_dir(setting["root_dir"])
  end
end

namespace :queue do
  desc 'Queue DB clear'
  task :clear do
    QueuedFile.destroy_all
  end
end

namespace :page_cache do
  desc 'Page Cache Clear'
  task :clear do
    FileUtils.rm(File.join(RAILS_ROOT, "public", "index.html")) if File.exist?(File.join(RAILS_ROOT, "public", "index.html"))
    FileUtils.rm_r(File.join(RAILS_ROOT, "public", "dir")) if File.exist?(File.join(RAILS_ROOT, "public", "dir"))
    FileUtils.rm_r(File.join(RAILS_ROOT, "public", "search")) if File.exist?(File.join(RAILS_ROOT, "public", "search"))
    FileUtils.rm_r(File.join(RAILS_ROOT, "public", "tag_search")) if File.exist?(File.join(RAILS_ROOT, "public", "tag_search"))
  end
end
