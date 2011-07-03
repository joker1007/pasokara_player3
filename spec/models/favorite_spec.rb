require 'spec_helper'

describe Favorite do
  it {should belong_to(:user)}
  it {should have_and_belong_to_many(:pasokara_files)}
end
