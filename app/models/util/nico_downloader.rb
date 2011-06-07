# _*_ coding: utf-8 _*_

require "rss"

module Util
  class NicoDownloader
    def initialize
      @agent = Mechanize.new
      @agent.read_timeout = 30
      @agent.open_timeout = 30
      @agent.max_history = 1
      @agent.user_agent_alias = 'Windows Mozilla'
      @logger = Logger.new(File.join(RAILS_ROOT, "log", "nico_downloader.log"))
      account = Pit.get("niconico", :require => {
        "mail" => "you email in niconico",
        "pass" => "your password in niconico"
      })
      @mail = account["mail"]
      @pass = account["pass"]
      @error_count = 0
      @rss_error_count = 0
    end
  
    def login?
      @agent.get("http://www.nicovideo.jp/").header["x-niconico-authflag"] != "0"
    end

    def login
      if @mail and @pass
        res = @agent.post 'https://secure.nicovideo.jp/secure/login?site=niconico','mail' => @mail,'password' => @pass
        res.header["x-niconico-authflag"] != "0"
      else
        raise "Login Error"
      end
    end

    def get_rss(rss_url)
      begin
        login
        @logger.info "[INFO] get rss data: #{rss_url}"
        page = @agent.get rss_url
        RSS::Parser.parse(page.body, true)
      rescue Exception
        @logger.fatal "[FATAL] get rss data failed: #{rss_url} #{$!}"
        @rss_error_count += 1
        raise "rss get error"
      end
    end

    def get_flv_url(nico_name)
      begin
        get_api = "http://www.nicovideo.jp/api/getflv/#{nico_name}"
        page = @agent.get get_api
        params = Hash[page.body.split("&").map {|value| value.split("=")}]
        url = URI.unescape(params["url"])
        @logger.info "[INFO] download url => #{url}"
        return url
      rescue Exception
        @logger.fatal "[FATAL] api access error: #{nico_name} #{$!}"
        @error_count += 1
        raise "api error"
      end
    end

    def get_info(nico_name)
      begin
        get_api = "http://www.nicovideo.jp/api/getthumbinfo/#{nico_name}"
        page = @agent.get get_api
        @logger.info "[INFO] movie info download completed: #{nico_name}"
        page.body
      rescue Exception
        @logger.fatal "[FATAL] api access error: #{nico_name} #{$!}"
        @error_count += 1
        raise "api error"
      end
    end


    def download(nico_name, dir = "/tmp/nicomovie")
      login
      @logger.info "[INFO] download sequence start: #{nico_name}"
      url = get_flv_url(nico_name)

      video_type_table = {"v" => "flv", "m" => "mp4", "s" => "swf"}
      url =~ /^http.*(?:nicovideo|smilevideo)\.jp\/smile\?(\w)=.*/
      video_type = video_type_table[$1] ? video_type_table[$1] : "flv"
      @logger.info "[INFO] download file type => #{video_type}"

      begin
        @agent.get("http://www.nicovideo.jp/watch/#{nico_name}")
      rescue Exception
        @logger.fatal "[FATAL] movie page load error: #{nico_name} #{$!}"
        @error_count += 1
        raise "movie page load error"
      end

      Dir.mkdir dir unless File.exist?(dir)
      movie_dir = File.join(dir, "#{nico_name}")
      Dir.mkdir movie_dir unless File.exist?(movie_dir)
      path = File.join(movie_dir, "#{nico_name}.#{video_type}")
      begin
        @logger.info "[INFO] download start: #{nico_name}"
        File.open(path, "w") do  |file|
          file.write @agent.get_file(url)
        end
        @logger.info "[INFO] download completed: #{nico_name}"
      rescue Exception
        @logger.fatal "[FATAL] download failed: #{nico_name} #{$!}"
        @error_count += 1
        raise "download failed"
      end

      sleep 5

      info_path = File.join(movie_dir, "#{nico_name}_info.xml")
      info = get_info(nico_name)
      File.open(info_path, "w") do  |file|
        file.write info
      end

      @logger.info "[INFO] download sequence completed: #{nico_name}"
      @error_count = 0
    end

    def rss_download(rss_url, dir = "/tmp/nicomovie")
      begin
        rss = get_rss(rss_url)
        @rss_error_count = 0
      rescue
        if @rss_error_count > 0 and @rss_error_count <= 3
          puts "Sleep 10 seconds"
          sleep 10
          puts "Retry #{rss_url}"
          retry
        else
          return false
        end
      end

      rss.items.each do |item|
        item.link =~ /^http.*\/watch\/(.*)/
        nico_name = $1
        unless PasokaraFile.find_by_nico_name(nico_name)
          begin
            download(nico_name, dir)
            puts "Load directory #{File.join(dir, nico_name)}"
            Util::DbStructer.new.crowl_dir(File.join(dir, nico_name))
          rescue
            if @error_count > 0 and @error_count <= 3
              puts "Sleep 10 seconds"
              sleep 10
              puts "Retry #{nico_name}"
              retry
            end
          end
          @error_count = 0
          puts "Sleep 7 seconds"
          sleep 7
        end
      end
    end

  end
end
