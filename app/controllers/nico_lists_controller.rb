# coding: utf-8
class NicoListsController < ApplicationController
  before_filter :authenticate_user!

  # GET /nico_lists
  # GET /nico_lists.xml
  def index
    @nico_lists = NicoList.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nico_lists }
    end
  end

  # GET /nico_lists/1
  # GET /nico_lists/1.xml
  def show
    @nico_list = NicoList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nico_list }
    end
  end

  # GET /nico_lists/new
  # GET /nico_lists/new.xml
  def new
    @nico_list = NicoList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nico_list }
    end
  end

  # GET /nico_lists/1/edit
  def edit
    @nico_list = NicoList.find(params[:id])
  end

  # POST /nico_lists
  # POST /nico_lists.xml
  def create
    @nico_list = NicoList.new(params[:nico_list])

    respond_to do |format|
      if @nico_list.save
        format.html {
          flash[:notice] = 'ダウンロードリストが追加されました'
          redirect_to(nico_lists_path)
        }
        format.json { render :json => @nico_list }
        format.xml  { render :xml => @nico_list, :status => :created, :location => @nico_list }
      else
        format.html { render :action => "new" }
        format.json { render :json => @nico_list.errors, :status => :unprocessable_entity  }
        format.xml  { render :xml => @nico_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nico_lists/1
  # PUT /nico_lists/1.xml
  def update
    @nico_list = NicoList.find(params[:id])

    respond_to do |format|
      if @nico_list.update_attributes(params[:nico_list])
        format.html { redirect_to(@nico_list, :notice => 'Nico list was successfully updated.') }
        format.json { render :json => @nico_list }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @nico_list.errors, :status => :unprocessable_entity  }
        format.xml  { render :xml => @nico_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /nico_lists/1
  # DELETE /nico_lists/1.xml
  def destroy
    @nico_list = NicoList.find(params[:id])
    @nico_list.destroy

    respond_to do |format|
      format.html { redirect_to(nico_lists_url) }
      format.xml  { head :ok }
    end
  end
end
