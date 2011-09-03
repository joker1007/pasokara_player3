# _*_ coding: utf-8 _*_

module Util
  class DbStructer

    def create_directory(attributes = {})
      directory = Directory.find_or_initialize_by(name: attributes[:name])
      directory.attributes = attributes

      if directory.new_record? or directory.changed?
        if directory.save
          # print_process directory
        else
          return nil
        end
      end

      return directory.id
    end

    def create_pasokara_file(attributes = {})
      pasokara_file = PasokaraFile.find_or_initialize_by(md5_hash: attributes[:md5_hash])
      pasokara_file.attributes = attributes
      pasokara_file.parse_info_file

      thumb_data = nico_check_thumb(pasokara_file.fullpath)
      if thumb_data && pasokara_file.thumbnail.size == 0
        pasokara_file.thumbnail = thumb_data
      end

      if pasokara_file.new_record? or pasokara_file.changed?
        if pasokara_file.save
          #print_process pasokara_file
        else
          p pasokara_file.errors if Rails.env == "test"
          return nil
        end
      end

      return pasokara_file.id
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
          elsif File.extname(entity) =~ /(mpg|avi|flv|ogm|mkv|mp4|wmv)/i
            begin
              unless PasokaraFile.saved_file?(entity_fullpath)
                EM.run do
                  ope = proc do
                    md5_hash = File.open(entity_fullpath) {|file| file.binmode; head = file.read(300*1024); Digest::MD5.hexdigest(head)}
                    video = RVideo::Inspector.new(:file => entity_fullpath)
                    duration = video.duration ? video.duration / 1000 : nil
                    attributes = {:name => name, :directory_id => higher_directory_id, :md5_hash => md5_hash, :duration => duration, :fullpath => entity_fullpath}
                  end

                  callback = proc do
                    pasokara_file_id = create_pasokara_file(attributes)
                    EM.stop_event_loop
                  end

                  EM.defer(ope, callback)
                end
              end
            rescue Exception
              puts "File Open Error: #{entity_fullpath}"
              puts $!
              puts $@
              next
            end
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
