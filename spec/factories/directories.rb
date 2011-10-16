# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :name do |n|
    "Directory#{n}"
  end

  factory :child_directory, :class => Directory do
    name
  end

  factory :directory do
    name

    after_build do |dir|
      3.times do
        child = Factory.build(:child_directory)
        dir.directories << child
      end

      pasokara_file = Factory.build(:pasokara_file)
      dir.directories << pasokara_file
    end
  end
end
