require 'spec_helper'

describe "directories/index.html.haml" do
  before(:each) do
    assign(:directories, [
      stub_model(Directory),
      stub_model(Directory)
    ])
  end

  it "renders a list of directories" do
    render
  end
end
