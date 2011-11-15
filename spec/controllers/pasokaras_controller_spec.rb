# coding: utf-8
require 'spec_helper'

describe PasokarasController do
  describe "GET encode_status" do
    context "エンコード中の時" do
      before do
        @pasokara = FactoryGirl.create(:pasokara_file)
        @pasokara.encoding = true
      end

      it "falseを返す" do
        get :encode_status, :id => @pasokara, :format => :json
        response.body.should == "false"
      end
    end

    context "エンコード中で無く" do
      context "エンコード済み動画ファイルが存在する時" do
        before do
          @pasokara = FactoryGirl.create(:pasokara_file, :id => "000000000000000000000000")
        end

        it "trueを返す" do
          get :encode_status, :id => @pasokara, :format => :json
          response.body.should == "true"
        end
      end

      context "エンコード済み動画ファイルが存在しない時" do
        before do
          @pasokara = FactoryGirl.create(:pasokara_file)
        end

        it "falseを返す" do
          get :encode_status, :id => @pasokara, :format => :json
          response.body.should == "false"
        end
      end
    end
  end

  describe "GET raw_file" do
    before { @pasokara = FactoryGirl.create(:pasokara_file) }

    it "fullpathで参照しているファイルそのものを返す" do
      get :raw_file, :id => @pasokara
      response.body.chomp.should == "1"
    end
  end
end
