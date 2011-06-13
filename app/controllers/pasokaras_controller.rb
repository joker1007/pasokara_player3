# coding: utf-8
class PasokarasController < ApplicationController
  before_filter :top_tag_load, :except => [:search, :thumb]

  def index
    @pasokaras = PasokaraFile.only(:id, :name, :nico_name, :duration).all
    respond_to do |format|
      format.xml {render :xml => @pasokaras}
      format.json {render :json => @pasokaras}
      format.txt {render :text => @pasokaras.map {|pasokara| pasokara.nico_name }.compact.join("\n")}
    end
  end

  def queue
    if params[:id] =~ /sm\d+/
      @pasokara = PasokaraFile.only(:id, :name, :nico_name, :duration, :fullpath).first(conditions: {nico_name: params[:id]})
    elsif params[:id] =~ /^[\w\d]+$/
      @pasokara = PasokaraFile.find(params[:id]).only(:id, :name, :nico_name, :duration, :fullpath)
    else
      render :text => "パラメーターが不正です。", :status => 404 and return
    end
    @pasokara.stream_path(request.raw_host_with_port, params[:force])
    #QueuedFile.enq @pasokara, current_user.id
    QueuedFile.enq @pasokara, nil
    

    @message = "#{@pasokara.name} の予約が完了しました"
    respond_to do |format|
      format.html {
        flash[:notice] = @message
        redirect_to root_path
      }
      format.js
      format.xml { render :xml => @message.to_xml }
      format.json { render :json => {:message => @message}.to_json }
    end
  end


  def search
    @query = params[:query]
    @filters = params[:filter] ? params[:filter].split(/\+/) : nil
    
    if @query
      queries = @query.split(/\s+/)
      case params[:field]
      when "n"
        @search = solr_name_search(queries, @filters)
      when "t"
        @search = solr_tag_search(queries, @filters)
      when "d"
        @search = solr_desc_search(queries, @filters)
      when "r"
        @search = solr_raw_search(@query, @filters)
      when "a"
        @search = solr_all_search(queries, @filters)
      else
        @search = solr_name_search(queries, @filters)
      end
    else
      @search = solr_noquery_search(@filters)
    end

    @header_tags = @search.facet(:tags).rows

    respond_to do |format|
      format.html
      format.js
      format.xml { render :xml => @search.results.to_xml }
      format.json { render :json => @search.results.to_json }
    end
  end

  def thumb
    send_file("#{Rails.root}/public/images/noimg-1_3.gif", :disposition => "inline", :type => "image/gif")
  end

  protected
  def solr_noquery_search(filters = nil)
    tag_filter = nil
    sort_order = solr_order_options
    search = Sunspot.search PasokaraFile do
      paginate(:page => params[:page], :per_page => per_page)
      if filters
        tag_filter = with(:tags).all_of filters
      end
      order_by sort_order[0], sort_order[1]
      facet :tags
    end
  end

  def solr_name_search(queries, filters = nil)
    tag_filter = nil
    sort_order = solr_order_options
    search = Sunspot.search PasokaraFile do
      keywords(queries, :fields => [:name])
      paginate(:page => params[:page], :per_page => per_page)
      if filters
        tag_filter = with(:tags).all_of filters
      end
      order_by sort_order[0], sort_order[1]
      facet :tags
    end
  end

  def solr_tag_search(queries, filters = nil)
    sort_order = solr_order_options
    search = Sunspot.search PasokaraFile do
      if filters
        tag_filter = with(:tags).all_of (queries + filters).uniq
      else
        tag_filter = with(:tags).all_of queries
      end
      paginate(:page => params[:page], :per_page => per_page)
      order_by sort_order[0], sort_order[1]
      facet :tags
    end
  end

  def solr_desc_search(queries, filters = nil)
    tag_filter = nil
    sort_order = solr_order_options
    search = Sunspot.search PasokaraFile do
      keywords(queries, :fields => [:nico_description])
      paginate(:page => params[:page], :per_page => per_page)
      if filters
        tag_filter = with(:tags).all_of filters
      end
      order_by sort_order[0], sort_order[1]
      facet :tags
    end
  end

  def solr_raw_search(query, filters = nil)
    tag_filter = nil
    sort_order = solr_order_options
    search = Sunspot.search PasokaraFile do
      adjust_solr_params do |p|
        p[:q] = query
      end
      paginate(:page => params[:page], :per_page => per_page)
      if filters
        tag_filter = with(:tags).all_of filters
      end
      order_by sort_order[0], sort_order[1]
      facet :tags
    end
  end

  def solr_all_search(queries, filters = nil)
    tag_filter = nil
    sort_order = solr_order_options
    solr_queries_temp = []
    solr_queries_temp << queries.map {|w| "name:#{w}"}.join(" AND ")
    solr_queries_temp << queries.map {|w| "tags:#{w}"}.join(" AND ")
    solr_queries_temp << queries.map {|w| "nico_description:#{w}"}.join(" AND ")
    solr_queries = solr_queries_temp.map {|q| "(#{q})"}.join(" OR ")
    search = Sunspot.search PasokaraFile do
      adjust_solr_params do |p|
        p[:q] = solr_queries
      end
      paginate(:page => params[:page], :per_page => per_page)
      if filters
        tag_filter = with(:tags).all_of filters
      end
      order_by sort_order[0], sort_order[1]
      facet :tags
    end
  end

  def set_solr_query(query)
    words = query.split(/\s+/)
    if words.empty?
      return "*.*"
    end

    case params[:field]
    when "n"
      solr_query = words.join(" AND ")
    when "t"
      solr_query = words.map {|w| "tag:#{w}"}.join(" AND ")
    when "d"
      solr_query = words.map {|w| "nico_description:#{w}"}.join(" AND ")
    when "r"
      solr_query = @query
    when "a"
      solr_query_temp = []
      solr_query_temp << words.map {|w| "name:#{w}"}.join(" AND ")
      solr_query_temp << words.map {|w| "tag:#{w}"}.join(" AND ")
      solr_query_temp << words.map {|w| "nico_description:#{w}"}.join(" AND ")
      solr_query = solr_query_temp.map {|q| "(#{q})"}.join(" OR ")
    else
      solr_query = words.join(" AND ")
    end
    solr_query
  end

  def solr_order_options
    order = [:name_str, :asc]
    case params[:sort]
    when "view_count"
      order = [:nico_view_counter, :desc]
    when "view_count_r"
      order = [:nico_view_counter, :asc]
    when "post_new"
      order = [:nico_post, :desc]
    when "post_old"
      order = [:nico_post, :asc]
    when "mylist_count"
      order = [:nico_mylist_counter, :desc]
    end

    order
  end

  def per_page
    50
  end
end
