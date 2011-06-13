require 'spec_helper'

describe "tags/index.html.haml" do
  before(:each) do
    assign(:tags, [
      stub_model(Tag),
      stub_model(Tag)
    ])
  end

  it "renders a list of tags" do
    render
  end
end
