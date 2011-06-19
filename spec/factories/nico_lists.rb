# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :nico_list do |f|
  f.url "http://www.test.com/test"
  f.download true
end
