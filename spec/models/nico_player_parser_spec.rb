# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NicoParser::NicoPlayerParser do

  it "NicoPlayer形式のinfoテキストからタグをパースして、配列で返すこと" do
    tags = NicoParser::NicoPlayerParser.new.parse_tag File.expand_path(File.dirname(__FILE__) + '/../romio_nico_player_info.txt')
    tags.should == [
      "歌ってみた",
      "ニコニコカラオケＤＢ",
      "ボカロカラオケDB",
      "よっぺい",
      "ロミオとシンデレラ",
      "黙ると死ぬ男",
      "原曲ブレイカー",
      "むしろこっちが原曲",
      "なぜ作ったし",
      "作業用BGM",
    ]
  end

  it "NicoPlayer形式のinfoテキストから動画情報をパースして、Hashで返すこと" do
    infos = NicoParser::NicoPlayerParser.new.parse_info File.expand_path(File.dirname(__FILE__) + '/../romio_nico_player_info.txt')
    infos.should == {
      :nico_name => "sm6875851",
      :nico_post => "2009/04/27 23:59:25",
      :nico_view_counter => 6431,
      :nico_comment_num => 340,
      :nico_mylist_counter => 229,
      :nico_description => "投稿者のコメント欄",
    }
  end
end
