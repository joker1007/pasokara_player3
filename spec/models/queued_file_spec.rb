# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe QueuedFile do
  fixtures :pasokara_files, :computers, :users

  before(:each) do
    @valid_attributes = {
      :pasokara_file_id => 8340,
    }

    @valid_attributes_user = {
      :pasokara_file_id => 8340,
      :user_id => 1,
    }

    @no_file_attributes = {
      :pasokara_file_id => 1111,
    }

    @just_be_friends = pasokara_files(:just_be_friends)
    @test_user1 = users(:test_user1)
  end

  it "適切なパラメーターで作成されること" do
    QueuedFile.create!(@valid_attributes)
    QueuedFile.create!(@valid_attributes_user)
  end

  it "PasokaraFileをキューに入れられること" do
    QueuedFile.delete_all
    QueuedFile.enq(@just_be_friends)
    QueuedFile.deq.pasokara_file.should == @just_be_friends
    QueuedFile.enq(@just_be_friends, 11)
    dequeued = QueuedFile.deq
    dequeued.pasokara_file.should == @just_be_friends
    dequeued.user.should == @test_user1
  end

  it "存在しないファイルIDをキューに入れようとするとエラーになること" do
    test_for_db_error do
      QueuedFile.create!(@no_file_attributes)
    end
  end
  
  it "dequeueされたときに、その曲の再生ログレコードが作成されること" do
    QueuedFile.enq @just_be_friends, 1
    dequeued = QueuedFile.deq
    SingLog.find(:last).pasokara_file.should == dequeued.pasokara_file
    SingLog.find(:last).user.should == dequeued.user
  end
end
