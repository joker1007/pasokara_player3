# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasokaraFile do

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
      it "/pasokara/preview/{id}という形式でファイルパスを返すこと" do
        siawase_gyaku.preview_path.should == "/pasokara/preview/#{siawase_gyaku.id}"
      end
    end

    describe "#duration_str" do
      it "mm:ss形式で曲の長さを返すこと" do
        pasokara_test.duration_str.should == "04:05"
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
    let(:tag1) {Factory(:tag, name: "Tag1")}
    let(:tag2) {Factory(:tag, name: "Tag2")}

    before(:each) do
      pasokara.tags << tag1
      pasokara.tags << tag2
    end

    describe "#tag_list" do
      it "自身が持つタグを示すTagListを返すこと" do
        pasokara.tag_list.should be_a(TagList)
        pasokara.tag_list.should include(tag1.name)
        pasokara.tag_list.should include(tag2.name)
      end
    end

    describe "after_save #save_tags" do
      it "tag_listへの追加分のタグを保存する" do
        expect {
          new_tag = "Tag3"
          pasokara.tag_list.add(new_tag)
          pasokara.save
          pasokara.tag_list.should include(new_tag)
          pasokara.tag_list.should have(3).items
        }.to change{ Tag.count }.from(2).to(3)

        expect {
          new_tags = ["Tag4", "Tag5"]
          pasokara.tag_list.should have(3).items
          pasokara.tag_list.add(new_tags)
          pasokara.save
          pasokara.tag_list.should include(*new_tags)
          pasokara.tag_list.should have(5).items
        }.to change{ Tag.count }.from(3).to(5)
      end

      it "tag_listからの削除分のタグを削除する" do
        expect {
          pasokara.tag_list.should have(2).items
          pasokara.tag_list.remove("Tag1")
          pasokara.save
          pasokara.tag_list.should_not include("Tag1")
          pasokara.tag_list.should have(1).items
        }.to change{ Tag.count }.from(2).to(1)
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
  end

  describe "検索するメソッド " do
    describe ".related_tags" do
      pending "引数で与えられたタグと関係するタグの配列を返すこと" do
      end
    end
  end

  describe "#do_encode(host)" do
    it "Resqueオブジェクトにエンコードジョブがenqueueされること" do
      Resque.should_receive(:enqueue).with(Job::VideoEncoder, @esp_raging.id, "host:port")
      @esp_raging.do_encode("host:port")
    end
  end

end
