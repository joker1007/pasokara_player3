# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :queued_file do
    name "Queue1"
    user_name "User1"
    pasokara_file
  end
end
