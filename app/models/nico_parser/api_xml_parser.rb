require "rexml/document"
require "rexml/streamlistener"
require "cgi"

module NicoParser
  class ApiXmlParser
    
    class MovieInfo
      attr_accessor :tags, :info
    end

    class InfoListener
      include REXML::StreamListener

      def initialize
        @info = MovieInfo.new
        @info.info = {}
        @info.tags = []
      end

      def tag_start(tag, attrs)
        @current_tag = tag
        @current_attrs = attrs
      end

      def text(text)
        if @current_tag =~ /(video_id|title|first_retrieve|view_counter|mylist_counter|comment_num|description)/
          if $1 == "video_id"
            key = "nico_name"
            val = text
          elsif $1 == "title"
            key = "name"
            val = text
          elsif $1 == "first_retrieve"
            key = "nico_post"
            val = text
          elsif $1 == "description"
            key = "nico_description"
            val = text
          else 
            key = "nico_" + $1
            val = text.to_i
          end
          @info.info.merge!(key.to_sym => val)
        elsif @current_tag == "tag" && text != ""
          @info.tags << CGI.unescapeHTML(text)
        end
      end

      def tag_end(tag)
        @current_tag = nil
        @current_attrs = nil
      end

      def movie_info
        @info
      end
    end

    def parse_xml(info_file)
      unless @movie_info
        @listener ||= InfoListener.new
        @body ||= File.read(info_file)
        REXML::Parsers::StreamParser.new(@body, @listener).parse
        @movie_info = @listener.movie_info
        @movie_info
      else
        @movie_info 
      end
    end

    
    def parse_tag(info_file)
      movie_info = parse_xml(info_file)
      movie_info.tags
    end

    def parse_info(info_file)
      movie_info = parse_xml(info_file)
      movie_info.info
    end

    def info_str(info_set = {}, tags = [])
      result = '<?xml version="1.0" encoding="UTF-8"?>' + "\n"

      if info_set[:nico_name]
        result += "<video_id>"
        result += info_set[:nico_name]
        result += "</video_id>\n"
      end

      if info_set[:nico_post]
        result += "<first_retrieve>"
        result += info_set[:nico_post].iso8601
        result += "</first_retrieve>\n"
      end

      tags.each do |tag|
        result += "<tag>"
        result += tag
        result += "</tag>\n"
      end

      if info_set[:nico_view_counter]
        result += "<view_counter>"
        result += info_set[:nico_view_counter].to_s
        result += "</view_counter>\n"
      end

      if info_set[:nico_comment_num]
        result += "<comment_num>"
        result += info_set[:nico_comment_num].to_s
        result += "</comment_num>\n"
      end

      if info_set[:nico_mylist_counter]
        result += "<mylist_counter>"
        result += info_set[:nico_mylist_counter].to_s
        result += "</mylist_counter>\n"
      end

      if info_set[:nico_description]
        result += "<description>"
        result += info_set[:nico_description]
        result += "</description>\n"
      end
    end
  end
end
