class HistoryController < ApplicationController
  before_filter :no_tag_load
  def index
    @sing_logs = SingLog.order_by([[:created_at, :desc]]).page params[:page]

    respond_to do |format|
      format.html
      format.js
      format.xml { render :xml => @sing_logs }
      format.json { render :json => @sing_logs }
    end
  end

end
