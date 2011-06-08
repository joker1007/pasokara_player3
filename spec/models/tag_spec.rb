# coding: utf-8
require 'spec_helper'

describe Tag do
  it "name無しでは保存できない" do
    tag = Tag.new
    tag.save.should be_false
  end
end
