# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :favorite do |f|
  f.pasokara_files {[Factory(:pasokara_file)]}
end
