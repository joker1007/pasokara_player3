# coding: utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag do |f|
    sequence(:name) {|n| "Tag#{n}" }
  end
end
