# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.sequence :dir_name_seq do |n|
  "Directory#{n}"
end

Factory.define :child_dir, :class => Directory do |f|
  f.name { Factory.next(:dir_name_seq) }
end

Factory.define :directory do |f|
  f.name "MyDirectory"
end
