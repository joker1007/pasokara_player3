# coding: utf-8
require 'spec_helper'

describe QueuesController do

  describe "GET deque.json" do
    let(:pasokara) {FactoryGirl.create(:pasokara_file)}
    let(:user) {FactoryGirl.create(:user)}

    before do
      QueuedFile.enq(pasokara, user)
    end

    it "PasokaraFileオブジェクトのJSONを返す" do
      QueuedFile.count.should == 1
      get :deque, :format => "json"
      QueuedFile.count.should == 0
      p_hash = JSON.parse response.body
      p_hash["name"].should == pasokara.name
    end
  end
end
