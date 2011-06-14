#_*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SingLog do
  let(:pasokara) {Factory(:pasokara_file)}
  let(:pasokara2) {Factory(:pasokara_file, name: "test002.flv")}
  let(:user) {Factory(:user)}

  before(:each) do
    @valid_attributes = {
      :name => pasokara.name,
      :pasokara_file_id => pasokara.id,
    }
    @valid_attributes_user = {
      :name => pasokara.name,
      :pasokara_file_id => pasokara.id,
      :user_name => user.nickname,
      :user_id => user.id
    }
    @no_name_attributes = {
      :pasokara_file_id => pasokara.id,
    }
    @no_pasokara_file_id = {
      :user_id => 2,
    }
    @no_user_id = {
      :pasokara_file_id => 8362,
    }
  end

  it "適切なパラメーターで作成されること(ユーザーなし)" do
    sing_log = SingLog.create!(@valid_attributes)
  end

  it "適切なパラメーターで作成されること(ユーザーあり)" do
    sing_log = SingLog.create!(@valid_attributes_user)
  end

  it "nameが無い場合はエラーになること" do
    sing_log = SingLog.new(@no_name_attributes)
    sing_log.save.should be_false
    sing_log.should have(1).errors_on(:name)
  end

  it "pasokara_fileとのリレーションが無い場合はエラーになること" do
    sing_log = SingLog.new
    sing_log.save.should be_false
    sing_log.should have(1).errors_on(:pasokara_file_id)
  end

  it "PasokaraFile, Userクラスと相互参照できること" do
    sing_log = SingLog.create!(@valid_attributes_user)
    sing_log.pasokara_file.should == pasokara
    sing_log.user.should == user
    pasokara.sing_logs.include?(sing_log).should be_true
    user.sing_logs.include?(sing_log).should be_true
  end
end
