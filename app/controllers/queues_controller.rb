# coding: utf-8
class QueuesController < ApplicationController
  def index
    @queue_list = QueuedFile.order_by([[:created_at, :asc]]).page params[:page]

    respond_to do |format|
      format.html
      format.js
      format.xml { render :xml => @queue_list }
      format.json { render :json => @queue_list }
    end
  end

  def deque
    @queue = QueuedFile.deq
    if @queue
      user = @queue.user
      pasokara_file = @queue.pasokara_file
      @queue.destroy
      if user and user.tweeting
        begin
          oauth.authorize_from_access(user.twitter_access_token, user.twitter_access_secret)
          client = Twitter::Base.new(oauth)
          tweet_body = "Singing Now: #{pasokara_file.name}"
          tweet_body += " http://www.nicovideo.jp/watch/#{pasokara_file.nico_name}" if pasokara_file.nico_name
          tweet_body += " #nicokara"
          client.update(tweet_body)
        rescue Exception
          logger.warn "#{user}'s Tweet Failed"
        end
      end

      respond_to do |format|
        format.html { redirect_to preview_pasokara_path(pasokara_file)}
        format.xml { render :xml => pasokara_file.to_xml }
        format.json { render :json => pasokara_file.to_json }
      end
    else
      render :text => "No Queue", :status => 404
    end
  end

  def destroy
    @queue = QueuedFile.find(params[:id])
    @queue.destroy
    message = "#{@queue.name}を予約から削除しました"

    respond_to do |format|
      format.html {
        flash[:notice] = message
        redirect_to queues_path
      }
      format.js
      format.xml { render :xml => @message.to_xml }
      format.json { render :json => {:message => @message}.to_json }
    end
  end

  def last
    @queue = QueuedFile.order_by([[:created_at, :desc]]).first

    if @queue
      respond_to do |format|
        format.xml  { render :xml => @queue.pasokara_file.to_xml }
        format.json { render :json => @queue.pasokara_file.to_json }
      end
    else
      render :text => "No Queue", :status => 404
    end
  end

end
