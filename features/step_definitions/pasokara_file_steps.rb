# coding: utf-8

include SolrSpecHelper

前提 /登録済みのパソカラが存在する/ do
  Factory(:pasokara_file)
  Factory(:siawase_gyaku)
end

前提 /登録済みかつwebmエンコード済みのパソカラが存在する/ do
  @pasokara = Factory(:pasokara_file, :id => "000000000000000000000000")
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
  visit preview_pasokara_path(@pasokara)
end

ならば /^フラッシュプレーヤーが表示されていること$/ do
  if page.respond_to? :should
    page.should have_xpath('//embed')
  else
    assert page.has_xpath?('//embed')
  end
end

ならば /^videoのファイルパスが表示されていること$/ do
  Then %{I should see "#{@pasokara.encode_filepath(:webm)}"}
end

ならば /^videoタグが表示されていること$/ do
  if page.respond_to? :should
    page.should have_xpath('//video')
  else
    assert page.has_xpath?('//video')
  end
end
