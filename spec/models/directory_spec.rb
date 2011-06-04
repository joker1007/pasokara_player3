# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Directory do
  before(:each) do
    @valid_attributes = {
      :name => "SOUND HOLIC",
    }

    @no_name_attributes = {
    }
  end

  it "適切なパラメーターで作成されること" do
    dir = Directory.new(@valid_attributes)
    dir.save!.should be_true
  end

  it "nameが無い場合バリデーションエラーになること" do
    dir = Directory.new(@no_name_attributes)
    dir.save.should be_false
    dir.should have(1).errors_on(:name)
  end

  it "entitiesメソッドで、下位ディレクトリ、ファイルのリストを返すこと" do
    dir = Factory.create(:directory)
    dir.stub(:directories) {[Factory(:child_dir), Factory(:child_dir), Factory(:child_dir)]}
    dir.stub(:pasokara_files) {[Factory(:pasokara_file)]}
    dir.should have(4).entities
  end

end
