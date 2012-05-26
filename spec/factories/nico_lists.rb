# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :nico_list do |f|
    url "http://www.test.com/test"
    download true
  end
end
