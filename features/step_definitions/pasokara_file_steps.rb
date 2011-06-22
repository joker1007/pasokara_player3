# coding: utf-8
前提 /登録済みのパソカラが存在する/ do
  Factory(:pasokara_file)
  Factory(:siawase_gyaku)
end

もし /^プレビューページを表示する$/ do
  pasokara = Factory(:pasokara_file)
  visit preview_pasokara_path(pasokara)
end

ならば /^フラッシュプレーヤーが表示されていること$/ do
  if page.respond_to? :should
    page.should have_xpath('//embed')
  else
    assert page.has_xpath?('//embed')
  end
end
