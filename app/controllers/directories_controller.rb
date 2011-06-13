class DirectoriesController < ApplicationController
  before_filter :top_tag_load

  # GET /directories
  # GET /directories.xml
  def index
    @directories = Directory.where(directory_id: nil).order_by([[:name, :asc]])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @directories }
      format.json  { render :json => @directories }
    end
  end

  def show
    unless params[:id]
      redirect_to :action => 'index' and return
    end

    @dir = Directory.find(params[:id])
    @subdir = @dir.directories.order_by([[:name, :asc]]).page params[:page]

    @pasokaras = @dir.pasokara_files.order_by([[:name, :asc]]).page params[:page]

    respond_to do |format|
      format.html
      format.xml { render :xml => [@subdir + @pasokaras].to_xml }
      format.json { render :json => [@subdir + @pasokaras].to_json }
    end
  end
end
