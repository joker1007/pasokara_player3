# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NicoParser::ApiXmlParser do

  it "ニコニコ動画API形式のXMLファイルからタグをパースして、配列で返すこと" do
    tags = NicoParser::ApiXmlParser.new.parse_tag File.expand_path(File.dirname(__FILE__) + '/../test_info.xml')
    tags.should == [
      "音楽",
      "ニコニコカラオケDB",
    ]
  end

  it "ニコニコ動画API形式のXMLファイルから動画情報をパースして、Hashで返すこと" do
    infos = NicoParser::ApiXmlParser.new.parse_info File.expand_path(File.dirname(__FILE__) + '/../test_info.xml')
    infos.should == {
      :nico_name => "sm9093985",
      :nico_post => "2009-12-14T21:29:11+09:00",
      :nico_view_counter => 318,
      :nico_comment_num => 6,
      :nico_mylist_counter => 10,
      :nico_description => "ばたふりゃ！●うｐした動画→mylist/16913119",
      :name => "[ニコカラ] えんどうさまのばたふりゃ",
    }
  end
end
