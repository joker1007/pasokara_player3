# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Directory do
  context "nameが与えられた時" do
    subject {FactoryGirl.build(:directory)}
    it "DB保存が成功すること" do
      subject.save.should be_true
    end
  end

  context "nameが与えられない時" do
    subject {FactoryGirl.build(:directory, :name => nil)}
    it "DB保存に失敗すること" do
      subject.save.should be_false
    end

    it "nameにエラーが存在すること" do
      subject.should have(1).errors_on(:name)
    end
  end

  describe "Method Test" do
    subject {create(:directory)}

    it {should have(4).entities}
  end

end
