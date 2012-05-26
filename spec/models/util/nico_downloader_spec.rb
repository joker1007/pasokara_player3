# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Util::NicoDownloader do

  before do
    @nico_downloader = Util::NicoDownloader.new
    @rss_url = "http://www.nicovideo.jp/tag/%E3%83%8B%E3%82%B3%E3%83%8B%E3%82%B3%E3%82%AB%E3%83%A9%E3%82%AA%E3%82%B1DB?page=1&sort=f&rss=2.0"
    @nico_name1 = "sm5860640"
  end

  it "#loginでニコニコ動画にログイン出来ること", :slow => true do
    @nico_downloader.login?.should be_false
    @nico_downloader.login
    @nico_downloader.login?.should be_true
  end

  context "ログイン後" do
    before do
      @nico_downloader.login
    end

    it "#get_rssで引数で与えたリストのrssを取得し、パース出来ること", :slow => true do
      rss = @nico_downloader.get_rss @rss_url
      rss.channel.generator.should eq("ニコニコ動画")
      rss.items.empty?.should be_false
    end

    it "#get_flv_urlで引数で与えたIDの動画のファイル本体のURLを取得する", :slow => true do
      url = @nico_downloader.get_flv_url(@nico_name1)
      url.should =~ /^http.*nicovideo/
    end

    it "#downloadで引数で与えたIDの動画ファイルをDLする", :slow => true do
      @nico_downloader.download(@nico_name1, "/tmp/nicomovie")
      File.exist?("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}.mp4").should be_true
      File.exist?("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}.jpg").should be_true
      File.exist?("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}_info.xml").should be_true
      File.unlink("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}.mp4")
      File.unlink("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}.jpg")
      File.unlink("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}_info.xml")
    end
  end

  describe "#get_nico_list" do
    context "nico_list.download == true" do
      let(:nico_list) { FactoryGirl.create(:nico_list) }
      it "#get_nico_listで引数で与えたNicoListオブジェクトからURLを取得し、get_rssに渡すこと" do
        @nico_downloader.should_receive(:get_rss).with(nico_list.url)
        @nico_downloader.get_nico_list(nico_list)
      end
    end

    context "nico_list.download == false" do
      let(:nico_list) { FactoryGirl.create(:nico_list, :download => false) }
      it "何もしないこと" do
        @nico_downloader.should_not_receive(:get_rss).with(nico_list.url)
        @nico_downloader.get_nico_list(nico_list)
      end
    end
  end
end
