# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Util::NicoDownloader do

  before do
    @nico_downloader = Util::NicoDownloader.new
    @rss_url = "http://www.nicovideo.jp/tag/%E3%83%8B%E3%82%B3%E3%83%8B%E3%82%B3%E3%82%AB%E3%83%A9%E3%82%AA%E3%82%B1DB?page=1&sort=f&rss=2.0"
    @nico_name1 = "sm5860640"
  end

  it "#loginでニコニコ動画にログイン出来ること" do
    @nico_downloader.login?.should be_false
    @nico_downloader.login
    @nico_downloader.login?.should be_true
  end

  it "#get_rssで引数で与えたリストのrssを取得し、パース出来ること" do
    @nico_downloader.login
    @nico_downloader.login?.should be_true
    rss = @nico_downloader.get_rss @rss_url
    rss.channel.generator.should == "ニコニコ動画"
    rss.items.empty?.should be_false
  end

  it "#get_flv_urlで引数で与えたIDの動画のファイル本体のURLを取得する" do
    @nico_downloader.login
    @nico_downloader.login?.should be_true
    url = @nico_downloader.get_flv_url(@nico_name1)
    url.should =~ /^http.*nicovideo/
  end

  it "#downloadで引数で与えたIDの動画ファイルをDLする" do
    @nico_downloader.login
    @nico_downloader.login?.should be_true
    @nico_downloader.download(@nico_name1, "/tmp/nicomovie")
    File.exist?("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}.mp4").should be_true
    File.exist?("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}_info.xml").should be_true
    File.unlink("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}.mp4")
    File.unlink("/tmp/nicomovie/#{@nico_name1}/#{@nico_name1}_info.xml")
  end
end
