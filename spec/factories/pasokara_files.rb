# encoding:utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

require "digest/md5"

Factory.sequence :mp4_name do |n|
  "test#{n}.mp4"
end

Factory.sequence :flv_name do |n|
  "test#{n}.flv"
end

Factory.define :pasokara_file do |f|
  f.name "test001.mp4"
  f.fullpath {|p| File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", p.name)}
  f.md5_hash {|p| Digest::MD5.hexdigest p.name }
  f.nico_name "sm999999"
  f.nico_post "2011-06-04 02:31:01"
  f.nico_view_counter 1
  f.nico_comment_num 1
  f.nico_mylist_counter 1
  f.duration 245
  f.nico_description "description"
  f.tags {["Tag1", "Tag2", "Tag3"]}
  f.encoding false
end

Factory.define :pasokara_file2, :class => PasokaraFile do |f|
  f.name "test002.mp4"
  f.fullpath {|p| File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", "testdir1", p.name)}
  f.md5_hash {|p| Digest::MD5.hexdigest p.name }
end

Factory.define :siawase_gyaku, :class => PasokaraFile do |f|
  f.name "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
  f.fullpath {|p| File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", p.name)}
  f.md5_hash {|a| Digest::MD5.hexdigest a.name }
  f.nico_name "sm4601746"
  f.nico_post "2011-06-04 02:31:01"
  f.nico_view_counter 2
  f.nico_comment_num 2
  f.nico_mylist_counter 2
  f.duration 2
  f.nico_description "description"
  f.tags {["Tag1", "Tag2", "Tag4"]}
  f.encoding false
end

