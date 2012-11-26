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
    @no_pasokara_id_attributes = {
      :name => pasokara.name,
    }
  end

  describe "オブジェクトの作成" do
    context "name, pasokara_file_idが与えられた時" do
      subject {QueuedFile.new(@valid_attributes)}

      it "DB保存に成功すること" do 
        subject.save.should be_true
      end

      its(:pasokara_file) {should == pasokara}
    end

    context "name, pasokara_file_id, user_idが与えられた時" do
      subject {QueuedFile.new(@valid_attributes_user)}

      it "DB保存に成功すること" do 
        subject.save.should be_true
      end

      its(:pasokara_file) {should == pasokara}
      its(:user) {should == user}
    end

    context "nameが与えられなかった場合" do
      subject {QueuedFile.new(@no_name_attributes)}

      it "DB保存に失敗すること" do 
        subject.save.should be_false
      end

      it {should have(1).errors_on(:name)}
    end

    context "pasokara_file_idが与えられなかった場合" do
      subject {QueuedFile.new(@no_pasokara_id_attributes)}

      it "DB保存に失敗すること" do 
        subject.save.should be_false
      end

      it {should have(1).errors_on(:pasokara_file_id)}
    end

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
    history = SingLog.last
    history.pasokara_file.should == dequeued.pasokara_file
    history.name.should == dequeued.pasokara_file.name
    history.user.should == dequeued.user
    history.user_name.should == dequeued.user.nickname
  end
end
