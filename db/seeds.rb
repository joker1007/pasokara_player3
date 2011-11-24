# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if admin = User.where(:name => "admin").first
  admin.password = "admin"
  admin.password_confirmation = "admin"
  admin.save
  puts "adminのパスワードを初期化しました。 ID/PASS : admin/admin"
else
  User.create({:name => "admin", :nickname => "admin", :password => "admin", :password_confirmation => "admin"})
  puts "初期ユーザーを作成しました。 ID/PASS : admin/admin"
end
