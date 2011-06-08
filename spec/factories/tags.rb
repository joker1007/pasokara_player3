# coding: utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.sequence :tag_name_seq do |n|
  "Tag#{n}"
end

Factory.define :tag do |f|
  f.name { Factory.next(:tag_name_seq) }
end
