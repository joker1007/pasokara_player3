require 'spec_helper'

describe User do
  it {should have_fields(:name, :nickname, :email, :tweeting, :twitter_access_token, :twitter_access_secret)}
  it {should have_and_belong_to_many(:favorites)}

  it {should validate_presence_of(:name)}
  it {should validate_uniqueness_of(:name)}
end
