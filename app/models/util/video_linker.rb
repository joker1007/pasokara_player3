# encoding: utf-8
module Util
  module VideoLinker
  
    def self.create_links
      video_dir = File.join(RAILS_ROOT, "public", "video")
      pasokaras = PasokaraFile.all(:select => "id, fullpath")
      system("rm -rf #{File.join(video_dir,"*")}")

      pasokaras.each do |pasokara|
        if pasokara.flv? || pasokara.mp4?
          subdir = File.join(video_dir, ((pasokara.id / 1000) * 1000).to_s)
          Dir.mkdir(subdir) unless File.exist?(subdir)
          puts "#{pasokara.fullpath} => #{File.join(subdir, pasokara.id.to_s + pasokara.extname)}"
          system("ln -s \"#{pasokara.fullpath}\" #{File.join(subdir, pasokara.id.to_s + pasokara.extname)}")
        end
      end
    end
  end
end
