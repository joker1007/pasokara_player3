require 'spec_helper'

describe "directories/show.html.haml" do
  before(:each) do
    @directory = assign(:directory, stub_model(Directory))
  end

  it "renders attributes in <p>" do
    render
  end
end
