require 'spec_helper'

describe PasokarasController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index', :format => "json"
      response.should be_success
    end
  end

  describe "GET 'search'" do
    it "should be successful" do
      get 'search', :query => "query", :field => "a", :filter => "filter"
      response.should be_success
    end
  end

end
