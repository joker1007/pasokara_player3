# coding: utf-8
require 'spec_helper'

describe PasokarasController do
  describe "GET encode_status" do
    context "エンコード中の時、戻り値が" do
      before do
        @pasokara = FactoryGirl.create(:pasokara_file)
        @pasokara.encoding = true

        get :encode_status, :id => @pasokara, :format => :json
        @data = ActiveSupport::JSON.decode(response.body)
      end

      subject { @data }

      its(["status"]) { should == false }
      its(["id"]) { should == @pasokara.id.to_s }
      its(["path"]) { should == @pasokara.encode_filepath(:webm) }
      its(["type"]) { should == "webm" }
    end

    context "エンコード中で無く" do
      context "エンコード済み動画ファイルが存在する時、戻り値が" do
        before do
          @pasokara = FactoryGirl.create(:pasokara_file, :id => "000000000000000000000000")
          get :encode_status, :id => @pasokara, :format => :json
          @data = ActiveSupport::JSON.decode(response.body)
        end

        subject { @data }

        its(["status"]) { should == true }
        its(["id"]) { should == @pasokara.id.to_s }
        its(["path"]) { should == @pasokara.encode_filepath(:webm) }
        its(["type"]) { should == "webm" }
      end

      context "エンコード済み動画ファイルが存在しない時" do
        before do
          @pasokara = FactoryGirl.create(:pasokara_file)
          get :encode_status, :id => @pasokara, :format => :json
          @data = ActiveSupport::JSON.decode(response.body)
        end

        subject { @data }

        its(["status"]) { should == false }
        its(["id"]) { should == @pasokara.id.to_s }
        its(["path"]) { should == @pasokara.encode_filepath(:webm) }
        its(["type"]) { should == "webm" }
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

  describe "GET play" do
    before do
      @queue = FactoryGirl.create(:queued_file)
      @pasokara = @queue.pasokara_file
      get :play, :format => :json
      @data = ActiveSupport::JSON.decode(response.body)
    end

    subject { @data }

    its(["id"]) { should == @pasokara.id.to_s }
    its(["path"]) { should == @pasokara.encode_filepath(:webm) }
    its(["type"]) { should == "webm" }
  end
end
