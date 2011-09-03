# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasokaraFile do
  include SolrSpecHelper

  it {should have_field(:name, :fullpath, :md5_hash, :nico_name, :nico_post, :nico_view_counter, :nico_comment_num, :nico_mylist_counter, :nico_description, :tags, :duration, :encoding)}
  it {should validate_presence_of(:name)}
  it {should validate_presence_of(:fullpath)}
  it {should validate_presence_of(:md5_hash)}

  before(:each) do
    @valid_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :fullpath => "/data/pasokara/COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }

    @nico_post_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
      :fullpath => "/data/pasokara/COOL&CREATE - ネココタマツリ.avi",
      :nico_post => Time.local(2010, 10, 10),
    }

    @nico_name_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
      :fullpath => "/data/pasokara/COOL&CREATE - ネココタマツリ.avi",
      :nico_name => "sm123456",
    }

    @no_name_attributes = {
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
      :fullpath => "/data/pasokara/COOL&CREATE - ネココタマツリ.avi",
    }

    @no_fullpath_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }


    @no_md5_hash__attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :fullpath => "/data/pasokara/COOL&CREATE - ネココタマツリ.avi",
    }

    #@cool_and_create = directories(:cool_and_create_dir)
    #@esp_raging = pasokara_files(:esp_raging)
    #@siawase_gyaku = pasokara_files(:siawase_gyaku)
    #@just_be_friends = pasokara_files(:just_be_friends)
  end

  it "適切なパラメーターで作成されること" do
    PasokaraFile.create!(@valid_attributes)
  end

  it "nameが無い場合DBエラーになること" do
    pasokara = PasokaraFile.new(@no_name_attributes)
    pasokara.save.should be_false
    pasokara.errors[:name].should_not be_nil
  end

  it "fullpathが無い場合DBエラーになること" do
    pasokara = PasokaraFile.new(@no_fullpath_attributes)
    pasokara.save.should be_false
    pasokara.errors[:fullpath].should_not be_nil
  end

  it "md5_hashが無い場合エラーになること" do
    pasokara = PasokaraFile.new(@no_md5_hash_attributes)
    pasokara.save.should be_false
    pasokara.errors[:md5_hash].should_not be_nil
  end

  it "ディレクトリに含まれることができる" do
    pasokara = Factory(:pasokara_file)
    directory = Factory(:directory)
    directory.pasokara_files << pasokara
    directory.should have(1).pasokara_files
    pasokara2 = Factory(:pasokara_file, name: Factory.next(:mp4_name))
    directory.pasokara_files << pasokara2
    directory.should have(2).pasokara_files
  end

  describe "値を取得するメソッド " do
    let(:pasokara_test) {Factory(:pasokara_file)}
    let(:siawase_gyaku) {Factory(:siawase_gyaku)}

    describe "#name()" do
      context "引数無し、または引数がtrueの時" do
        it "UTF-8でnameを返すこと" do
          siawase_gyaku.name.should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
          siawase_gyaku.name(true).should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
        end
      end

      context "引数がfalseの時" do
        it "CP932でnameを返すこと" do
          siawase_gyaku.name(false).encoding.should == Encoding::Windows_31J
        end
      end
    end

    describe "#extname" do
      it "fullpathの拡張子を返すこと" do
        pasokara_test.extname.should == ".mp4"
        siawase_gyaku.extname.should == ".flv"
      end
    end

    describe "#movie_path" do
      it "/video/{id}という形式でファイルパスを返すこと" do
        siawase_gyaku.movie_path.should == "/video/#{siawase_gyaku.id}.flv"
      end
    end

    describe "#preview_path" do
      it "/pasokaras/preview/{id}という形式でファイルパスを返すこと" do
        siawase_gyaku.preview_path.should == "/pasokaras/preview/#{siawase_gyaku.id}"
      end
    end

    describe "#duration_str" do
      it "mm:ss形式で曲の長さを返すこと" do
        pasokara_test.duration_str.should == "04:05"
      end

      it "durationがnilの場合は00:00を返すこと" do
        pasokara_test.duration = nil
        pasokara_test.duration_str.should == "00:00"
      end
    end

    describe "#nico_post_str" do
      it "yyyy/mm/ddのフォーマットで投稿日時を返すこと" do
        pasokara_test.nico_post_str.should == "2011/06/04"
      end
    end

    describe "#nico_url" do
      it "ニコニコ動画へのリンクURLを返すこと" do
        pasokara_test.nico_url.should == "http://www.nicovideo.jp/watch/" + pasokara_test.nico_name
      end
    end

    describe "#stream_prefix" do
      it "\"{id}-stream\"という文字列を返すこと" do
        id = siawase_gyaku.id
        siawase_gyaku.stream_prefix.should == "#{id}-stream"
      end
    end

    describe "#m3u8_filename" do
      it "\"{stream_prefix}.m3u8\"という文字列を返すこと" do
        stream_prefix = siawase_gyaku.stream_prefix
        siawase_gyaku.m3u8_filename.should == "#{stream_prefix}.m3u8"
      end
    end

    describe "#m3u8_path" do
      it "\"/video/{m3u8_filename}\"という文字列を返すこと" do
        m3u8_filename = siawase_gyaku.m3u8_filename
        siawase_gyaku.m3u8_path.should == "/video/#{m3u8_filename}"
      end
    end
  end

  describe "Tagに関するメソッド" do
    let(:pasokara) {Factory(:pasokara_file)}

    describe "#tag_list" do
      it "自身が持つタグを示すTagListを返すこと" do
        pasokara.tag_list.should be_a(TagList)
        pasokara.tag_list.should include("Tag1")
        pasokara.tag_list.should include("Tag2")
        pasokara.tag_list.should include("Tag3")
      end
    end

    describe "after_save #save_tags" do
      it "tag_listへの追加分のタグを保存する" do
        tag1 = Factory(:tag, name: "Tag1", size: 1)
        tag2 = Factory(:tag, name: "Tag2", size: 1)
        tag3 = Factory(:tag, name: "Tag3", size: 1)
        expect {
          new_tag = "Tag4"
          pasokara.tag_list.add(new_tag)
          pasokara.save
          pasokara.tag_list.should include(new_tag)
          pasokara.tag_list.should have(4).items
        }.to change{ Tag.count }.from(3).to(4)

        expect {
          new_tags = ["Tag4", "Tag5"]
          pasokara.tag_list.should have(4).items
          pasokara.tag_list.add(new_tags)
          pasokara.save
          pasokara.tag_list.should include(*new_tags)
          pasokara.tag_list.should have(5).items
        }.to change{ Tag.count }.from(4).to(5)
      end

      it "tag_listからの削除分のタグを削除する" do
        tag1 = Factory(:tag, name: "Tag1", size: 1)
        tag2 = Factory(:tag, name: "Tag2", size: 1)
        tag3 = Factory(:tag, name: "Tag3", size: 1)
        expect {
          pasokara.tag_list.should have(3).items
          pasokara.tag_list.remove("Tag1")
          pasokara.save
          pasokara.tag_list.should_not include("Tag1")
          pasokara.tag_list.should have(2).items
          tag1.size.should == 0
        }
      end
    end
  end

  describe "状態を確認するメソッド " do
    let(:mp4_file) {Factory(:pasokara_file)}
    let(:flv_file) {Factory(:pasokara_file, name: "test002.flv")}
    let(:no_exist_mp4_file) {Factory(:pasokara_file, name: "test003.mp4")}
    let(:no_exist_flv_file) {Factory(:pasokara_file, name: "test004.flv")}

    describe "#mp4?" do
      context "ファイルが存在し、拡張子がmp4のファイルである時" do
        it "trueを返すこと" do
          mp4_file.mp4?.should be_true
        end
      end
      context "ファイルが存在しない時" do
        it "falseを返すこと" do
          no_exist_mp4_file.mp4?.should be_false
        end
      end
    end

    describe "#flv?" do
      context "ファイルが存在し、拡張子がflvのファイルである時" do
        it "trueを返すこと" do
          flv_file.flv?.should be_true
        end
      end
      context "ファイルが存在しない時" do
        it "falseを返すこと" do
          no_exist_flv_file.flv?.should be_false
        end
      end
    end

    describe "#encoded?" do
      context "エンコードが開始され、m3u8ファイルが存在している時" do
        it "trueを返すこと" do
          m3u8_file = File.join(Rails.root, "public", mp4_file.m3u8_path)
          system("touch #{m3u8_file}")
          mp4_file.encoded?.should be_true
          File.delete(m3u8_file)
        end
      end

      context "m3u8ファイルが存在しない時" do
        it "falseを返すこと" do
          mp4_file.encoded?.should be_false
        end
      end
    end

    describe "self.saved_file?(fullpath)" do
      context "fullpathが存在する時" do
        let(:pasokara_file) {Factory(:pasokara_file)}

        it "trueを返すこと" do
          PasokaraFile.saved_file?(pasokara_file.fullpath).should be_true
        end
      end

      context "fullpathが存在しない時" do
        it "falseを返すこと" do
          fullpath = "/tmp/nofile.mp4"
          PasokaraFile.saved_file?(fullpath).should be_false
        end
      end
    end
  end

  describe "#do_encode(host)" do
    let(:flv_file) {Factory(:pasokara_file, name: "test002.flv")}
    it "Resqueオブジェクトにエンコードジョブがenqueueされること" do
      Resque.should_receive(:enqueue).with(Job::VideoEncoder, flv_file.id, "host:port")
      flv_file.do_encode("host:port")
    end
  end

  describe "infoファイルのパース" do
    let(:pasokara_file) {Factory.build(:pasokara_file2)}
    it "同じディレクトリにある、(ファイル名)_info.xmlをパースして情報を取得できること" do
      pasokara_file.nico_name.should be_nil
      pasokara_file.nico_post.should be_nil
      pasokara_file.nico_view_counter.should be_nil
      pasokara_file.nico_comment_num.should be_nil
      pasokara_file.nico_mylist_counter.should be_nil
      pasokara_file.nico_description.should be_nil
      pasokara_file.tag_list.should be_empty

      pasokara_file.parse_info_file

      pasokara_file.nico_name.should == "sm99999999"
      pasokara_file.nico_post.should == Time.local(2011, 7, 21, 3, 29, 1)
      pasokara_file.nico_view_counter.should == 7
      pasokara_file.nico_comment_num.should == 3
      pasokara_file.nico_mylist_counter.should == 2
      pasokara_file.nico_description.should == "test description"
      pasokara_file.tag_list.should be_include "VOCALOID"
      pasokara_file.tag_list.should be_include "tag2"
    end
  end

  describe "Sunspotによる検索" do
    it "nameによる全文検索が出来ること", :slow => true do
      solr_setup
      PasokaraFile.remove_all_from_index!

      pasokara = Factory(:pasokara_file)
      pasokara2 = Factory(:pasokara_file, name: "sunspot.mp4")
      Sunspot.commit

      search = Sunspot.search PasokaraFile
      search.results.should be_include(pasokara)
      search.results.should be_include(pasokara2)

      search = Sunspot.search PasokaraFile do
        keywords "sunspot.mp4"
      end
      search.results.should_not be_include(pasokara)
      search.results.should be_include(pasokara2)

      PasokaraFile.remove_all_from_index!
    end
  end

end
