# coding:utf-8
module NicoParser
  class NicoPlayerParser

    def info_name2key(info_name)
      table = {
        "name" => "nico_name",
        "post" => "nico_post",
        "view_counter" => "nico_view_counter",
        "comment_num" => "nico_comment_num",
        "mylist_counter" => "nico_mylist_counter",
        "comment" => "nico_description",
      }

      table[info_name]
    end

    def parse_tag(info_file)
      tag_mode = false
      tags = []

      if File.exist?(info_file)
        File.open(info_file, "r:utf-16le") {|file|
          converted = file.read
          converted.each_line do |line|
            if line.chop.empty?
              tag_mode = false
            end

            if tag_mode == true
              tags << line.chop
            end

            if line.chop == "[tags]"
              tag_mode = true
            end
          end
        }
      end
      tags.map do |tag|
        CGI.unescapeHTML(tag)
      end
    end

    def parse_info(info_file)
      parse_mode = false
      info_set = {}
      info_key = ""

      if File.exist?(info_file)
        File.open(info_file, "r:utf-16le") {|file|
          converted = file.read
          converted.each_line do |line|
            if line.chomp.empty?
              parse_mode = false
            end

            if parse_mode == true
              if info_key == "view_counter" or info_key == "comment_num" or info_key == "mylist_counter"
                value = line.chomp.to_i
              else
                value = line.chomp
              end
              info_key = info_name2key(info_key)
              info_set.merge!(info_key.to_sym => value)
            end

            if line.chomp =~ /\[(.*)\]/
              next unless ($1 == "name" or $1 == "post" or $1 == "view_counter" or $1 == "comment_num" or $1 == "mylist_counter" or $1 == "comment")
              parse_mode = true
              info_key = $1
            end
          end
        }
      end
      info_set
    end

    def info_str(info_set = {}, tags = [])
      result = ""
      if info_set[:nico_name]
        result += "[name]\n"
        result += info_set[:nico_name] + "\n"
        result += "\n"
      end
      if info_set[:nico_post]
        result += "[post]\n"
        result += info_set[:nico_post].strftime("%Y/%m/%d %H:%M:%S") + "\n"
        result += "\n"
      end
      unless tags.empty?
        result += "[tags]\n"
        tags.each do |tag|
          result += tag + "\n"
        end
        result += "\n"
      end
      if info_set[:nico_view_counter]
        result += "[view_counter]\n"
        result += info_set[:nico_view_counter].to_s + "\n"
        result += "\n"
      end
      if info_set[:nico_comment_num]
        result += "[comment_num]\n"
        result += info_set[:nico_comment_num].to_s + "\n"
        result += "\n"
      end
      if info_set[:nico_mylist_counter]
        result += "[mylist_counter]\n"
        result += info_set[:nico_mylist_counter].to_s + "\n"
        result += "\n"
      end
      result
    end
  end
end
