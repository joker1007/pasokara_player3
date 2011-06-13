require 'spec_helper'

describe QueueController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'deque'" do
    it "should be successful" do
      get 'deque'
      response.should be_success
    end
  end

  describe "GET 'remove'" do
    it "should be successful" do
      get 'remove'
      response.should be_success
    end
  end

  describe "GET 'last'" do
    it "should be successful" do
      get 'last'
      response.should be_success
    end
  end

end
