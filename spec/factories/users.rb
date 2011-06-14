# coding: utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.name "login"
  f.email "user@test.com"
  f.nickname "ユーザー"
  f.tweeting false
  f.favorites {[Factory(:pasokara_file)]}
end
