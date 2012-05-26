# coding: utf-8
前提 /登録済みのダウンロードリストが存在する/ do
  FactoryGirl.create(:nico_list, :url => "http://www.first.com/")
  FactoryGirl.create(:nico_list, :url => "http://www.second.com/")
end

もし /^ダウンロードリスト編集ページを表示する$/ do
  nico_list = FactoryGirl.create(:nico_list)
  visit edit_nico_list_path(nico_list)
end

ならば /^ダウンロードリストの一覧が表示されていること$/ do
  nico_list = NicoList.all[0]
  step %{入力項目"nico_list_url_#{nico_list.id}"に"http://www.first.com/"と表示されていること}
  nico_list = NicoList.all[1]
  step %{入力項目"nico_list_url_#{nico_list.id}"に"http://www.second.com/"と表示されていること}
end
