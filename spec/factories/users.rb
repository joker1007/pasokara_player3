# coding: utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.name "login"
  f.email "user@test.com"
  f.nickname "ニックネーム1"
  f.tweeting false
  f.password "password"
  f.password_confirmation "password"
  f.favorites {[Factory(:pasokara_file)]}
end
