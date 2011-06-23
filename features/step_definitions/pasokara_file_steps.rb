# coding: utf-8

include SolrSpecHelper

前提 /登録済みのパソカラが存在する/ do
  Factory(:pasokara_file)
  Factory(:siawase_gyaku)
end

前提 /パソカラがインデックス化されている/ do
  solr_setup
  PasokaraFile.remove_all_from_index!

  PasokaraFile.all.each do |p|
    p.index
  end
  Sunspot.commit
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
