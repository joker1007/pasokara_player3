# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QueuedFile do
  let(:pasokara) {Factory(:pasokara_file)}
  let(:pasokara2) {Factory(:pasokara_file, name: "test002.flv")}

  before(:each) do
    @valid_attributes = {
      :pasokara_file_id => pasokara.id,
    }

    @valid_attributes_user = {
      :pasokara_file_id => 8340,
      :user_id => 1,
    }

    @no_file_attributes = {
      :pasokara_file_id => 1111,
    }
  end

  it "適切なパラメーターで作成されること(ユーザーなし)" do
    queue = QueuedFile.create!(@valid_attributes)
    queue.pasokara_file.should == pasokara
  end

  it "pasokara_fileとのリレーションが無い場合はエラーになること" do
    queue = QueuedFile.new
    queue.save.should be_false
    queue.should have(1).errors_on(:pasokara_file_id)
  end

  pending "適切なパラメーターで作成されること(ユーザーあり)" do
    #QueuedFile.create!(@valid_attributes_user)
  end

  it "PasokaraFileをキューに入れられること(ユーザーなし)" do
    QueuedFile.enq(pasokara2)
    QueuedFile.deq.pasokara_file.should == pasokara2
  end

  pending "PasokaraFileをキューに入れられること(ユーザーあり)" do
    QueuedFile.enq(pasokara, 11)
    dequeued = QueuedFile.deq
    dequeued.pasokara_file.should == pasokara
    dequeued.user.should == @test_user1
  end

  pending "dequeueされたときに、その曲の再生ログレコードが作成されること" do
    QueuedFile.enq @just_be_friends, 1
    dequeued = QueuedFile.deq
    SingLog.find(:last).pasokara_file.should == dequeued.pasokara_file
    SingLog.find(:last).user.should == dequeued.user
  end
end
