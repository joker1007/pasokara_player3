# _*_ coding: utf-8 _*_

require "solr"

module Util
  class SolrIndexer

    def self.indexing
      solr = Solr::Connection.new("http://#{SOLR_SERVER}/solr")
      PasokaraFile.all.each do |pasokara|
        puts pasokara.id.to_s + ":" + pasokara.name
        solr.add(solr_key(pasokara))
      end

      solr.commit
      solr.optimize
    end

    def self.single_indexing(pasokara)
      solr = Solr::Connection.new("http://#{SOLR_SERVER}/solr")
      puts pasokara.id.to_s + ":" + pasokara.name
      solr.add(solr_key(pasokara))

      solr.commit
      solr.optimize
    end

    private
    def self.solr_key(pasokara)
      key = {}
      key.merge!({:id => pasokara.id})
      key.merge!({:name => pasokara.name}) if pasokara.name
      key.merge!({:nico_name => pasokara.nico_name}) if pasokara.nico_name
      key.merge!({:nico_view_counter => pasokara.nico_view_counter}) if pasokara.nico_view_counter
      key.merge!({:nico_comment_num => pasokara.nico_comment_num}) if pasokara.nico_comment_num
      key.merge!({:nico_mylist_counter => pasokara.nico_mylist_counter}) if pasokara.nico_mylist_counter
      key.merge!({:nico_description => pasokara.nico_description}) if pasokara.nico_description
      key.merge!({:nico_post => pasokara.nico_post}) if pasokara.nico_post
      key.merge!({:duration => pasokara.duration}) if pasokara.duration
      key.merge!({:tag => pasokara.tag_list}) unless pasokara.tag_list.empty?
      key
    end
  end
end

