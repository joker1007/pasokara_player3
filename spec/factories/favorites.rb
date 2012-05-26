# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :favorite do |f|
    pasokara_files {[Factory(:pasokara_file)]}
  end
end
