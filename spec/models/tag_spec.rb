# coding: utf-8
require 'spec_helper'

describe Tag do
  it {should validate_presence_of(:name)}
end
