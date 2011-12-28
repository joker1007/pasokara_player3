class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_encode_mode

  protected
  def top_tag_load
    tag_limit = 50

    @tag_list_cache_key = "top_tags_#{tag_limit}"
    @header_tags = Tag.order_by([[:size, :desc], [:name, :asc]]).limit(tag_limit)
    @header_tags.each do |tag|
      tag.instance_variable_set(:@query, params[:tag])
      def tag.link_options
        {:controller => "pasokara", :action => "append_search_tag", :append => name, :tag => @query}
      end
    end
    true
  end

  def no_tag_load
    @no_tag_load = true
  end

  def set_encode_mode
    session[:encode_mode] ||= :webm
  end
end
