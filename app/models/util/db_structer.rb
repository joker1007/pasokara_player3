# _*_ coding: utf-8 _*_

module Util
  class DbStructer

    def create_directory(attributes = {})
      already_record = Directory.first(conditions: {name: attributes[:name]})

      if already_record
        if already_record.directory_id != attributes[:directory_id]
          already_record.directory_id = attributes[:directory_id]
          already_record.save
        end

        return already_record.id
      end
      
      directory = Directory.new(attributes)
      if directory.save
        # print_process directory
        return directory.id
      else
        return nil
      end
    end

    def create_pasokara_file(attributes = {}, tags = [])
      already_record = PasokaraFile.first(conditions: {md5_hash: attributes[:md5_hash]})
      pasokara_file = PasokaraFile.new(attributes)
      pasokara_file.tag_list.add tags if tags.any?
      if already_record

        changed = false

        if already_record.name != pasokara_file.name
          already_record.name = pasokara_file.name
          changed = true
        end

        if already_record.fullpath != pasokara_file.fullpath
          already_record.fullpath = pasokara_file.fullpath
          changed = true
        end

        if already_record.directory_id != pasokara_file.directory_id
          already_record.directory_id = pasokara_file.directory_id
          changed = true
        end

        if already_record.duration != pasokara_file.duration
          already_record.duration = pasokara_file.duration
          changed = true
        end

        if already_record.tag_list.empty? and !pasokara_file.tag_list.empty?
          already_record.tag_list.add pasokara_file.tag_list
          changed = true
        end

        if already_record.nico_name.nil? and !pasokara_file.nico_name.nil?
          already_record.nico_name = pasokara_file.nico_name
          changed = true
        end

        if already_record.nico_post.nil? and !pasokara_file.nico_post.nil?
          already_record.nico_post = pasokara_file.nico_post
          changed = true
        end

        if already_record.nico_view_counter.nil? and !pasokara_file.nico_view_counter.nil?
          already_record.nico_view_counter = pasokara_file.nico_view_counter
          changed = true
        end

        if already_record.nico_comment_num.nil? and !pasokara_file.nico_comment_num.nil?
          already_record.nico_comment_num = pasokara_file.nico_comment_num
          changed = true
        end

        if already_record.nico_mylist_counter.nil? and !pasokara_file.nico_mylist_counter.nil?
          already_record.nico_mylist_counter = pasokara_file.nico_mylist_counter
          changed = true
        end

        if already_record.nico_description.nil? and !pasokara_file.nico_description.nil?
          already_record.nico_description = pasokara_file.nico_description
          changed = true
        end

        thumb_data = nico_check_thumb(already_record.fullpath)
        if thumb_data && already_record.thumbnail.size == 0
          already_record.thumbnail = thumb_data
          changed = true
        end

        if changed
          already_record.save
          p already_record.errors if Rails.env == "test"
          #print_process already_record
        end
        return already_record.id
      else
        thumb_data = nico_check_thumb(pasokara_file.fullpath)
        if thumb_data
          pasokara_file.thumbnail = thumb_data
        end

        if pasokara_file.save
          #print_process pasokara_file
          return pasokara_file.id
        else
          p pasokara_file.errors if Rails.env == "test"
          return nil
        end
      end
    end

    def crowl_dir(dir, higher_directory_id = nil,  force_thumbnail = false)
      puts "#{dir}の読み込み開始\n"

      begin
        open_dir = Dir.open(dir)
        open_dir.entries.each do |entity|
          next if entity =~ /^\./
          entity_fullpath = File.join(dir, entity)

          name = entity

          if File.directory?(entity_fullpath)
            attributes = {:name => name, :directory_id => higher_directory_id}

            dir_id = create_directory(attributes)
            crowl_dir(entity_fullpath, dir_id, force_thumbnail)
          elsif File.extname(entity) =~ /(mpg|avi|flv|ogm|mkv|mp4|wmv|swf)/i
            begin
              md5_hash = File.open(entity_fullpath) {|file| file.binmode; head = file.read(300*1024); Digest::MD5.hexdigest(head)}
              video = RVideo::Inspector.new(:file => entity_fullpath)
              duration = video.duration ? video.duration / 1000 : nil
            rescue Exception
              puts "File Open Error: #{entity_fullpath}"
              puts $!
              puts $@
              next
            end
            attributes = {:name => name, :directory_id => higher_directory_id, :md5_hash => md5_hash, :duration => duration, :fullpath => entity_fullpath}
            info_file, parser = check_info_file(entity_fullpath)

            tags = parser.parse_tag(info_file)
            attributes.merge!(parser.parse_info(info_file))

            pasokara_file_id = create_pasokara_file(attributes, tags)

          end
        end
      rescue Errno::ENOENT
        puts "Dir Open Error"
      end
    end

    private

    def check_info_file(fullpath)
      api_xml_file = fullpath.gsub(/\.[0-9a-zA-Z]+$/, "_info.xml")
      nico_player_info_file = fullpath.gsub(/\.[0-9a-zA-Z]+$/, ".txt")

      if File.exists?(api_xml_file)
        [api_xml_file, NicoParser::ApiXmlParser.new]
      else
        [nico_player_info_file, NicoParser::NicoPlayerParser.new]
      end
    end

    def nico_check_thumb(fullpath)
      thumb = fullpath.gsub(/#{Regexp.escape(File.extname(fullpath))}$/, ".jpg")
      if File.exist?(thumb)
        File.open(thumb)
      else
        nil
      end
    end

    def print_process(record)
      puts "#{record.class}: #{record.id}"
    end
  end
end
