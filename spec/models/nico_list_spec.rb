#coding: utf-8
require 'spec_helper'

describe NicoList do
  it { should have_field(:url) }
  it { should have_field(:download).of_type(Boolean).with_default_value_of(true) }
  it { should validate_presence_of(:url) }
  it { should validate_uniqueness_of(:url) }
end
