# encoding:utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

require "digest/md5"

FactoryGirl.define do
  sequence :mp4_name do |n|
    "test#{n}.mp4"
  end

  sequence :flv_name do |n|
    "test#{n}.flv"
  end

  factory :pasokara_file do |f|
    name "test001.mp4"
    fullpath {|p| File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", p.name)}
    md5_hash {|p| Digest::MD5.hexdigest p.name }
    nico_name "sm999999"
    nico_post "2011-06-04 02:31:01"
    nico_view_counter 1
    nico_comment_num 1
    nico_mylist_counter 1
    duration 245
    nico_description "description"
    tags {["Tag1", "Tag2", "Tag3"]}
    encoding false
  end

  factory :pasokara_file2, :class => PasokaraFile do |f|
    name "test002.mp4"
    fullpath {|p| File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", "testdir1", p.name)}
    md5_hash {|p| Digest::MD5.hexdigest p.name }
  end

  factory :siawase_gyaku, :class => PasokaraFile do |f|
    name "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
    fullpath {|p| File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", p.name)}
    md5_hash {|a| Digest::MD5.hexdigest a.name }
    nico_name "sm4601746"
    nico_post "2011-06-04 02:31:01"
    nico_view_counter 2
    nico_comment_num 2
    nico_mylist_counter 2
    duration 245
    nico_description "description"
    tags {["Tag1", "Tag2", "Tag4"]}
    encoding false
  end
end
