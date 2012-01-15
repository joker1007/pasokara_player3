# coding: utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do |f|
    name "login"
    email "user@test.com"
    nickname "ニックネーム1"
    tweeting false
    password "password"
    password_confirmation "password"
  end
end
