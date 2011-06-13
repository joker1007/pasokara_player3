class HistoryController < ApplicationController
  before_filter :no_tag_load
  def index
    @sing_logs = SingLog.order_by([[:created_at, :desc]]).page params[:page]
  end

end
