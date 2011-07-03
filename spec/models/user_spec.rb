# coding: utf-8
require 'spec_helper'

describe User do
  it {should have_fields(:name, :nickname, :email, :tweeting, :twitter_access_token, :twitter_access_secret)}
  it {should have_one(:favorite)}

  it {should validate_presence_of(:name)}
  it {should validate_uniqueness_of(:name)}

  describe "#add_favorite" do
    it "PasokaraFileをお気に入り登録できること" do
      user = Factory(:user, :favorite => nil)
      pasokara = Factory(:siawase_gyaku)
      user.add_favorite pasokara

      user.favorite.pasokara_files.first.should == pasokara
    end
  end

  describe "#favorite?" do
    it "PasokaraFileがお気に入り登録されているかをBooleanで返すこと" do
      user = Factory(:user, :favorite => nil)
      pasokara = Factory(:siawase_gyaku)
      no_favorite = Factory(:pasokara_file)
      user.add_favorite pasokara

      user.favorite?(pasokara).should be_true
      user.favorite?(no_favorite).should be_false
    end
  end
end
