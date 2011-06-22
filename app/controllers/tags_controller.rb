class TagsController < ApplicationController
  before_filter :no_tag_load
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.order_by([[:size, :desc]]).page params[:page]

    respond_to do |format|
      format.html
      format.xml  { render :xml => @tags }
      format.json { render :json => @tags }
    end
  end

  def search
    @tags = Tag.order_by([[:size, :desc]]).where(name: /#{Regexp.escape(params[:tag])}/).page params[:page]

    respond_to do |format|
      format.html { render :action => "index" }
      format.js
      format.xml  { render :xml => @tags }
      format.json { render :json => @tags }
    end
  end
end
