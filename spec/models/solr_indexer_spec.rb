# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Util::SolrIndexer do
  before do
    @solr_mock = mock_model(Solr::Connection)
  end

  it "self.indexing" do
    Solr::Connection.should_receive(:new).and_return(@solr_mock)
    pasokaras = PasokaraFile.all
    pasokaras.each do |pasokara|
      solr_key = {}
      solr_key.merge!({:id => pasokara.id})
      solr_key.merge!({:name => pasokara.name}) if pasokara.name
      solr_key.merge!({:nico_name => pasokara.nico_name}) if pasokara.nico_name
      solr_key.merge!({:nico_view_counter => pasokara.nico_view_counter}) if pasokara.nico_view_counter
      solr_key.merge!({:nico_comment_num => pasokara.nico_comment_num}) if pasokara.nico_comment_num
      solr_key.merge!({:nico_mylist_counter => pasokara.nico_mylist_counter}) if pasokara.nico_mylist_counter
      solr_key.merge!({:nico_description => pasokara.nico_description}) if pasokara.nico_description
      solr_key.merge!({:nico_post => pasokara.nico_post}) if pasokara.nico_post
      solr_key.merge!({:duration => pasokara.duration}) if pasokara.duration
      solr_key.merge!({:tag => pasokara.tag_list}) unless pasokara.tag_list.empty?
      @solr_mock.should_receive(:add).with(solr_key)
    end

    @solr_mock.should_receive(:commit)
    @solr_mock.should_receive(:optimize)

    Util::SolrIndexer.indexing
  end

  it "self.single_indexing" do
    Solr::Connection.should_receive(:new).and_return(@solr_mock)
    pasokara = pasokara_files(:esp_raging)
    solr_key = {}
    solr_key.merge!({:id => pasokara.id})
    solr_key.merge!({:name => pasokara.name}) if pasokara.name
    solr_key.merge!({:nico_name => pasokara.nico_name}) if pasokara.nico_name
    solr_key.merge!({:nico_view_counter => pasokara.nico_view_counter}) if pasokara.nico_view_counter
    solr_key.merge!({:nico_comment_num => pasokara.nico_comment_num}) if pasokara.nico_comment_num
    solr_key.merge!({:nico_mylist_counter => pasokara.nico_mylist_counter}) if pasokara.nico_mylist_counter
    solr_key.merge!({:nico_description => pasokara.nico_description}) if pasokara.nico_description
    solr_key.merge!({:nico_post => pasokara.nico_post}) if pasokara.nico_post
    solr_key.merge!({:duration => pasokara.duration}) if pasokara.duration
    solr_key.merge!({:tag => pasokara.tag_list}) unless pasokara.tag_list.empty?
    @solr_mock.should_receive(:add).with(solr_key)

    @solr_mock.should_receive(:commit)
    @solr_mock.should_receive(:optimize)

    Util::SolrIndexer.single_indexing(pasokara)
  end
end
