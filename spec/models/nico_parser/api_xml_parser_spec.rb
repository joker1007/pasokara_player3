# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NicoParser::ApiXmlParser do

  it "ニコニコ動画API形式のXMLファイルからタグをパースして、配列で返すこと" do
    tags = NicoParser::ApiXmlParser.new.parse_tag File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "datas", "testdir1", "test002_info.xml")
    tags.should == [
      "VOCALOID",
      "tag2",
    ]
  end

  it "ニコニコ動画API形式のXMLファイルから動画情報をパースして、Hashで返すこと" do
    infos = NicoParser::ApiXmlParser.new.parse_info File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "datas", "testdir1", "test002_info.xml")
    infos.should == {
      :nico_name => "sm99999999",
      :nico_post => "2011-07-21T03:29:01+09:00",
      :duration => 205,
      :nico_view_counter => 7,
      :nico_comment_num => 3,
      :nico_mylist_counter => 2,
      :nico_description => "test description",
      :name => "test002.mp4",
    }
  end
end
