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
  end

  describe "オブジェクトの作成" do
    context "name, fullpath, md5_hashが与えられた時" do
      subject {PasokaraFile.new(@valid_attributes)}
      it {subject.save!.should be_true}
    end

    context "nameが無い時" do
      subject {PasokaraFile.new(@no_name_attributes)}
      it {subject.save.should be_false}
      it {subject.errors[:name].should_not be_nil}
    end

    context "fullpathが無い時" do
      subject {PasokaraFile.new(@no_fullpath_attributes)}
      it {subject.save.should be_false}
      it {subject.errors[:fullpath].should_not be_nil}
    end

    context "md5_hashが無い時" do
      subject {PasokaraFile.new(@no_md5_hash_attributes)}
      it {subject.save.should be_false}
      it {subject.errors[:md5_hash].should_not be_nil}
    end
  end

  describe "ファイルから読み込む", :file_load => true do
    before { @pasokara = PasokaraFile.load_file(File.join(File.dirname(__FILE__), "..", "datas", "testdir1", "test002.mp4")) }
    subject { @pasokara }

    its(:nico_name) { should == "sm99999999" }
  end

  describe "ディレクトリからファイルを読み込む", :file_load => true do
    it {
      expect {
        PasokaraFile.load_dir(File.join(File.dirname(__FILE__), "..", "datas"))
      }.to change {PasokaraFile.count}.from(0).to(3)
    }

    it {
      PasokaraFile.load_dir(File.join(File.dirname(__FILE__), "..", "datas"))
      pasokara = PasokaraFile.where(:nico_name => "sm99999999").first
      pasokara.should_not be_nil
      pasokara.directory.should_not be_nil
    }

    it {
      PasokaraFile.load_dir(File.join(File.dirname(__FILE__), "..", "datas"))
      pasokara = PasokaraFile.where(:name => "test001.mp4")[0]
      pasokara.thumbnail.size.should == 5872
      pasokara.directory.should be_nil
    }

    context "既にファイルが登録されている時" do
      before do
        PasokaraFile.load_dir(File.join(File.dirname(__FILE__), "..", "datas"))
      end

      it {
        PasokaraFile.where(:nico_name => "sm99999999").count.should == 1
      }
    end

    context "既にディレクトリが登録されている時" do
      before { create(:directory, :name => "testdir1") }

      it {
        PasokaraFile.load_dir(File.join(File.dirname(__FILE__), "..", "datas", "testdir1"))
        pasokara = PasokaraFile.where(:nico_name => "sm99999999").first
        pasokara.should_not be_nil
        pasokara.directory.should_not be_nil
      }
    end
  end

  it "ディレクトリに含まれることができる" do
    directory = FactoryGirl.create(:directory)
    pasokara = FactoryGirl.create(:pasokara_file)
    pasokara2 = FactoryGirl.create(:pasokara_file, name: "test002.mp4")

    expect {
      directory.pasokara_files << pasokara
      directory.pasokara_files << pasokara2
    }.to change { directory.pasokara_files.length }.from(0).to(2)
  end

  describe "値を取得するメソッド " do
    subject {FactoryGirl.create(:siawase_gyaku)}

    describe "#name()" do

      context "引数無し、または引数がtrueの時" do
        it "UTF-8でnameを返すこと" do
          subject.name.should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
          subject.name(true).should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
        end
      end

      context "引数がfalseの時" do
        it "CP932でnameを返すこと" do
          subject.name(false).encoding.should == Encoding::Windows_31J
        end
      end
    end

    describe "#extname" do
      its(:extname) {should == ".flv"}
    end

    describe "#movie_path" do
      it "/video/{id}という形式でファイルパスを返すこと" do
        subject.movie_path.should == "/video/#{subject.id}.flv"
      end
    end

    describe "#preview_path" do
      it "/pasokaras/preview/{id}という形式でファイルパスを返すこと" do
        subject.preview_path.should == "/pasokaras/preview/#{subject.id}"
      end
    end

    describe "#duration_str" do
      it "mm:ss形式で曲の長さを返すこと" do
        subject.duration_str.should == "04:05"
      end

      context "durationがnilの場合" do
        before {subject.duration = nil}
        its(:duration_str) {should == "00:00"}
      end
    end

    describe "#nico_post_str" do
      its(:nico_post_str) {should == "2011/06/04"}
    end

    describe "#nico_url" do
      it "ニコニコ動画へのリンクURLを返すこと" do
        subject.nico_url.should == "http://www.nicovideo.jp/watch/" + subject.nico_name
      end
    end

    describe "#encode_prefix" do
      context "引数が無い場合" do
        it { subject.encode_prefix.should == "#{subject.id}-safari" }
      end
      context "引数が'stream'の場合" do
        it { subject.encode_prefix(:stream).should == "#{subject.id}-stream" }
      end
    end

    describe "#encode_filename" do
      context "引数が無い場合" do
        it { subject.encode_filename.should == "#{subject.id}-safari.mp4" }
      end
      context "引数が'stream'の場合" do
        it { subject.encode_filename(:stream).should == "#{subject.id}-stream.m3u8" }
      end
      context "引数が'webm'の場合" do
        it { subject.encode_filename(:webm).should == "#{subject.id}-webm.webm" }
      end
    end

    describe "#encode_filepath" do
      it "\"/video/{encode_filename}\"という文字列を返すこと" do
        subject.encode_filepath.should == "/video/#{subject.encode_filename}"
      end
    end
  end

  describe "Tagに関するメソッド" do
    subject {Factory(:pasokara_file)}
    before do
      @tag1 = Factory(:tag, name: "Tag1", size: 1)
      @tag2 = Factory(:tag, name: "Tag2", size: 1)
      @tag3 = Factory(:tag, name: "Tag3", size: 1)
    end

    describe "#tag_list" do
      it "自身が持つタグを示すTagListを返すこと" do
        subject.tag_list.should be_a(TagList)
        subject.tag_list.should include("Tag1")
        subject.tag_list.should include("Tag2")
        subject.tag_list.should include("Tag3")
      end
    end

    describe "after_save #save_tags" do
      it "tag_listへの追加分のタグを保存する" do
        expect {
          new_tag = "Tag4"
          subject.tag_list.add(new_tag)
          subject.save
          subject.tag_list.should include(new_tag)
          subject.tag_list.should have(4).items
        }.to change{ Tag.count }.from(3).to(4)
      end

      it "重複したタグは追加されない" do
        new_tag = "Tag4"
        subject.tag_list.add(new_tag)
        subject.save
        expect {
          new_tags = ["Tag4", "Tag5"]
          subject.tag_list.should have(4).items
          subject.tag_list.add(new_tags)
          subject.save
          subject.tag_list.should include(*new_tags)
          subject.tag_list.should have(5).items
        }.to change{ subject.tag_list.count }.from(4).to(5)
      end

      it "tag_listからの削除分のタグを削除する" do
        expect {
          subject.tag_list.should have(3).items
          subject.tag_list.remove("Tag1")
          subject.save
          subject.tag_list.should_not include("Tag1")
          subject.tag_list.should have(2).items
        }.to change {subject.tag_list.count}.from(3).to(2)
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
        subject {mp4_file}
        its(:mp4?) {should be_true}
      end
      context "ファイルが存在しない時" do
        subject {no_exist_mp4_file}
        its(:mp4?) {should be_false}
      end
    end

    describe "#flv?" do
      context "ファイルが存在し、拡張子がflvのファイルである時" do
        subject {flv_file}
        its(:flv?) {should be_true}
      end
      context "ファイルが存在しない時" do
        subject {no_exist_flv_file}
        its(:flv?) {should be_false}
      end
    end

    describe "#encoded?" do
      subject {create(:pasokara_file, :id => "000000000000000000000000")}
      context "エンコードが開始され、ファイルが存在している時" do
        context "引数が無い時" do
          its(:encoded?) {should be_true}
        end
        context "引数が:webmの時" do
          it {subject.encoded?(:webm).should be_true}
        end
      end

      context "ファイルが存在しない時" do
        subject {create(:pasokara_file, :id => "000000000000000000000001")}
        its(:encoded?) {should be_false}
        it {subject.encoded?(:webm).should be_false}
      end
    end

    describe "self.saved_file?(fullpath)" do
      subject {PasokaraFile}
      context "fullpathが存在する時" do
        before {@pasokara_file = create(:pasokara_file)}

        it {subject.saved_file?(@pasokara_file.fullpath).should be_true}
      end

      context "fullpathが存在しない時" do
        let(:fullpath) {"/tmp/nofile.mp4"}
        it {subject.saved_file?(fullpath).should be_false}
      end
    end
  end

  describe "#do_encode(host)" do
    context "ファイル形式の指定が無い時" do
      subject { create(:pasokara_file, name: "test002.flv") }
      it "Resqueクラスにエンコードジョブがenqueueされること" do
        Resque.should_receive(:enqueue).with(Job::VideoEncoder, subject.id, "host:port", :safari)
        subject.do_encode("host:port")
      end
    end

    context "ファイル形式の指定がある時" do
      subject { create(:pasokara_file, name: "test002.flv") }
      it "Resqueクラスにエンコードジョブがenqueueされること" do
        Resque.should_receive(:enqueue).with(Job::VideoEncoder, subject.id, "host:port", :chrome)
        subject.do_encode("host:port", :chrome)
      end
    end
  end

  describe "infoファイルのパース" do
    subject {Factory.build(:pasokara_file2)}
    it "同じディレクトリにある、(ファイル名)_info.xmlをパースして情報を取得できること" do
      subject.nico_name.should be_nil
      subject.nico_post.should be_nil
      subject.nico_view_counter.should be_nil
      subject.nico_comment_num.should be_nil
      subject.nico_mylist_counter.should be_nil
      subject.nico_description.should be_nil
      subject.tag_list.should be_empty

      subject.parse_info_file

      subject.nico_name.should == "sm99999999"
      post_time = Time.xmlschema("2011-07-21T03:29:01+09:00")
      subject.nico_post.should == post_time
      subject.nico_view_counter.should == 7
      subject.nico_comment_num.should == 3
      subject.nico_mylist_counter.should == 2
      subject.nico_description.should == "test description"
      subject.tag_list.should be_include "VOCALOID"
      subject.tag_list.should be_include "tag2"
    end
  end

  describe "サムネイルを作成する" do
    context "サムネイルが存在する時" do
      subject {create(:pasokara_file)}
      it "サムネイル作成が行われないこと" do
        FFmpegInfo.should_not_receive(:getinfo)
        FFmpegThumbnailer.should_not_receive(:create)
        subject.create_thumbnail
      end
    end

    context "サムネイルが存在しない時" do
      subject {create(:pasokara_file2, :duration => 245)}
      it "fullpathとdurationをベースにライブラリ関数が呼ばれること" do
        FFmpegInfo.should_receive(:getinfo).with(subject.fullpath).and_return({:duration => subject.duration})
        FFmpegThumbnailer.should_receive(:create).with(subject.fullpath, 25)
        subject.create_thumbnail
      end
    end
  end

  describe "サムネイルを更新する" do
    context "サムネイルが存在する時" do
      subject {create(:pasokara_file)}

      its(:thumbnail_path) {should == File.join(Rails.root, "spec", "factories", "..", "datas", "test001.jpg")}
      its(:exist_thumbnail?) {should be_true}
      its(:update_thumbnail) {should be_true}
    end

    context "サムネイルが存在しない時" do
      subject {create(:pasokara_file2)}
      its(:thumbnail_path) {should == File.join(Rails.root, "spec", "factories", "..", "datas", "testdir1", "test002.jpg")}
      its(:exist_thumbnail?) {should be_false}
      its(:update_thumbnail) {should be_false}
    end
  end

  describe "Sunspotによる検索", :slow => true do
    before do
      solr_setup
      PasokaraFile.remove_all_from_index!
      @pasokara = create(:pasokara_file)
      @pasokara2 = create(:pasokara_file, name: "sunspot.mp4")
      Sunspot.commit
    end

    after do
      PasokaraFile.remove_all_from_index!
    end

    it "nameによる全文検索が出来ること" do
      search = Sunspot.search PasokaraFile
      search.results.should be_include(@pasokara)
      search.results.should be_include(@pasokara2)

      search = Sunspot.search PasokaraFile do
        keywords "sunspot.mp4"
      end
      search.results.should_not be_include(@pasokara)
      search.results.should be_include(@pasokara2)
    end
  end

end
