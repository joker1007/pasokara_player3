require "spec_helper"

describe DirectoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/directories").should route_to("directories#index")
    end

    it "routes to #new" do
      get("/directories/new").should route_to("directories#new")
    end

    it "routes to #show" do
      get("/directories/1").should route_to("directories#show", :id => "1")
    end

    it "routes to #edit" do
      get("/directories/1/edit").should route_to("directories#edit", :id => "1")
    end

    it "routes to #create" do
      post("/directories").should route_to("directories#create")
    end

    it "routes to #update" do
      put("/directories/1").should route_to("directories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/directories/1").should route_to("directories#destroy", :id => "1")
    end

  end
end
