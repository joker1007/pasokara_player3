# coding: utf-8
require 'spec_helper'

describe User do
  it {should have_fields(:name, :nickname, :email, :tweeting, :twitter_access_token, :twitter_access_secret)}
  it {should have_one(:favorite)}

  it {should validate_presence_of(:name)}
  it {should validate_uniqueness_of(:name)}

  before do
    @user = create(:user, :favorite => nil)
    @pasokara = create(:siawase_gyaku)
  end

  describe "#add_favorite(pasokara)" do
    subject {@user}
    before {subject.add_favorite @pasokara}

    it "お気に入りに登録できること" do
      subject.favorite.pasokara_files.first.should == @pasokara
    end
  end

  describe "#favorite?(pasokara)" do
    context "お気に入りが登録されている時" do
      subject {@user}
      before {subject.add_favorite @pasokara}

      it {subject.favorite?(@pasokara).should be_true}
    end

    context "お気に入りが登録されていない時" do
      subject {@user}
      before {@no_favored = create(:pasokara_file)}

      it {subject.favorite?(@no_favored).should be_false}
    end

  end
end
