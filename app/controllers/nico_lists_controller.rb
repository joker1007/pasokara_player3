# coding: utf-8
class NicoListsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_check

  # GET /nico_lists
  # GET /nico_lists.json
  def index
    @nico_list = NicoList.new
    @nico_lists = NicoList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @nico_lists }
    end
  end

  # GET /nico_lists/1
  # GET /nico_lists/1.json
  def show
    @nico_list = NicoList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @nico_list }
    end
  end

  # GET /nico_lists/new
  # GET /nico_lists/new.json
  def new
    @nico_list = NicoList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @nico_list }
    end
  end

  # GET /nico_lists/1/edit
  def edit
    @nico_list = NicoList.find(params[:id])
  end

  # POST /nico_lists
  # POST /nico_lists.json
  def create
    @nico_list = NicoList.new(params[:nico_list])

    respond_to do |format|
      if @nico_list.save
        format.html {
          flash[:notice] = 'ダウンロードリストが追加されました'
          redirect_to(nico_lists_path)
        }
        format.js {
          html_str = render_to_string "_row", :locals => {:nico_list => @nico_list}
          render :text => html_str
        }
        format.json { render :json => @nico_list, :status => :created }
      else
        format.html { render :action => "new" }
        format.js   { render :json => @nico_list.errors, :status => :unprocessable_entity }
        format.json { render :json => @nico_list.errors, :status => :unprocessable_entity  }
      end
    end
  end

  # PUT /nico_lists/1
  # PUT /nico_lists/1.json
  def update
    @nico_list = NicoList.find(params[:id])

    respond_to do |format|
      if @nico_list.update_attributes(params[:nico_list])
        format.html { redirect_to(@nico_list, :notice => 'Nico list was successfully updated.') }
        format.json { render :json => @nico_list }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @nico_list.errors, :status => :unprocessable_entity  }
      end
    end
  end

  # DELETE /nico_lists/1
  # DELETE /nico_lists/1.json
  def destroy
    @nico_list = NicoList.find(params[:id])
    @nico_list.destroy

    respond_to do |format|
      format.html { redirect_to(nico_lists_url) }
      format.json  { head :ok }
    end
  end

  private
  def admin_check
    unless current_user.try(:admin)
      redirect_to root_url
      false
    end
  end
end
