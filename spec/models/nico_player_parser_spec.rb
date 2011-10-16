# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NicoParser::NicoPlayerParser do

  before do
    @tags = NicoParser::NicoPlayerParser.new.parse_tag File.expand_path(File.dirname(__FILE__) + '/../romio_nico_player_info.txt')
    @infos = NicoParser::NicoPlayerParser.new.parse_info File.expand_path(File.dirname(__FILE__) + '/../romio_nico_player_info.txt')
  end

  describe "タグのパース" do
    subject {@tags}
    it "NicoPlayer形式のinfoテキストからタグをパースして、配列で返すこと" do
      subject.should == [
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
  end

  describe "動画情報のパース" do
    subject {@infos}
    it "NicoPlayer形式のinfoテキストから動画情報をパースして、Hashで返すこと" do
      subject.should == {
        :nico_name => "sm6875851",
        :nico_post => "2009/04/27 23:59:25",
        :nico_view_counter => 6431,
        :nico_comment_num => 340,
        :nico_mylist_counter => 229,
        :nico_description => "投稿者のコメント欄",
      }
    end
  end
end
