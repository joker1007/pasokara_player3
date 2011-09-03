# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QueuedFile do
  let(:pasokara) {FactoryGirl.create(:pasokara_file)}
  let(:pasokara2) {FactoryGirl.create(:pasokara_file, name: "test002.flv")}
  let(:user) {FactoryGirl.create(:user)}

  before(:each) do
    @valid_attributes = {
      :name => pasokara.name,
      :pasokara_file_id => pasokara.id,
    }
    @valid_attributes_user = {
      :name => pasokara.name,
      :pasokara_file_id => pasokara.id,
      :user_name => user.name,
      :user_id => user.id
    }
    @no_name_attributes = {
      :pasokara_file_id => pasokara.id,
    }
  end

  it "適切なパラメーターで作成されること(ユーザーなし)" do
    queue = QueuedFile.create!(@valid_attributes)
    queue.pasokara_file.should == pasokara
  end

  it "nameが無い場合はエラーになること" do
    queue = QueuedFile.new(@no_name_attributes)
    queue.save.should be_false
    queue.should have(1).errors_on(:name)
  end

  it "pasokara_fileとのリレーションが無い場合はエラーになること" do
    queue = QueuedFile.new
    queue.save.should be_false
    queue.should have(1).errors_on(:pasokara_file_id)
  end

  it "適切なパラメーターで作成されること(ユーザーあり)" do
    queue = QueuedFile.create!(@valid_attributes_user)
  end

  it "PasokaraFileをキューに入れられること(ユーザーなし)" do
    QueuedFile.enq(pasokara2)
    QueuedFile.deq.pasokara_file.should == pasokara2
  end

  it "PasokaraFileをキューに入れられること(ユーザーあり)" do
    QueuedFile.enq(pasokara, user)
    dequeued = QueuedFile.deq
    dequeued.pasokara_file.should == pasokara
    dequeued.name.should == pasokara.name
    dequeued.user_name.should == user.nickname
  end

  it "dequeueされたときに、その曲の再生ログレコードが作成されること" do
    QueuedFile.count.should == 0
    QueuedFile.enq(pasokara2, user)
    dequeued = QueuedFile.deq
    history = SingLog.find(:last)
    history.pasokara_file.should == dequeued.pasokara_file
    history.name.should == dequeued.pasokara_file.name
    history.user.should == dequeued.user
    history.user_name.should == dequeued.user.nickname
  end
end
