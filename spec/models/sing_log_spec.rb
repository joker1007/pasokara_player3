#_*_ coding: utf-8 _*_
require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe SingLog do
  fixtures :pasokara_files, :users, :sing_logs

  before(:each) do
    @valid_attributes = {
      :pasokara_file_id => 8362,
      :user_id => 2,
    }
    @no_pasokara_file_id = {
      :user_id => 2,
    }
    @no_exist_pasokara_file_id = {
      :pasokara_file_id => 99999,
      :user_id => 2,
    }
    @no_user_id = {
      :pasokara_file_id => 8362,
    }
    @no_exist_user_id = {
      :pasokara_file_id => 8362,
      :user_id => 99999,
    }

    @esp_test1_logs = sing_logs(:esp_test1_logs)

    @esp_raging = pasokara_files(:esp_raging)
    @siawase_gyaku = pasokara_files(:siawase_gyaku)
    @just_be_friends = pasokara_files(:just_be_friends)

    @test_user1 = users(:test_user1)
    @test_user2 = users(:test_user2)
  end

  it "適切なパラメーターで作成されること" do
    sing_log = SingLog.create!(@valid_attributes)
  end

  it "pasokara_file_idが無いパラメーターはDBエラーになること" do
    test_for_db_error do
      sing_log = SingLog.new(@no_pasokara_file_id)
      sing_log.save_with_validation(false)
    end
  end
  
  it "存在しないpasokara_file_idパラメーターはDBエラーになること" do
    test_for_db_error do
      sing_log = SingLog.new(@no_exist_pasokara_file_id)
      sing_log.save_with_validation(false)
    end
  end

  it "user_idパラメーターが無くても作成できること" do
    sing_log = SingLog.create!(@no_user_id)
    sing_log.pasokara_file.should == @siawase_gyaku
  end
  
  it "存在しないuser_idパラメーターはDBエラーになること" do
    test_for_db_error do
      sing_log = SingLog.new(@no_exist_pasokara_file_id)
      sing_log.save_with_validation(false)
    end
  end

  it "PasokaraFile, Userクラスと相互参照できること" do
    @esp_test1_logs.pasokara_file.should == @esp_raging
    @esp_test1_logs.user.should == @test_user1
    @esp_raging.sing_logs.include?(@esp_test1_logs).should be_true
    @test_user1.sing_logs.include?(@esp_test1_logs).should be_true
  end
end
