# coding: utf-8
前提 /^登録済みユーザーが存在する$/ do
  u = FactoryGirl.create(:user, :admin => true)
  u.add_favorite(FactoryGirl.create(:pasokara_file))
end

前提 /^登録済みユーザー2が存在する$/ do
  u = FactoryGirl.create(:user, :name => "login2", :nickname => "ニックネーム2")
  u.add_favorite(FactoryGirl.create(:pasokara_file))
end

前提 /^ユーザーID:"([^"]*)"、パスワード:"([^"]*)"でログインしている$/ do |login, password|
  visit new_user_session_path
  fill_in("ユーザーID", :with => login)
  fill_in("パスワード", :with => password)
  click_button("ログイン")
end

Given /^the following users:$/ do |users|
  User.create!(users.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) user$/ do |pos|
  visit users_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following users:$/ do |expected_users_table|
  expected_users_table.diff!(tableish('table tr', 'td,th'))
end
