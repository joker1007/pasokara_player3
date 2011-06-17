# encoding: utf-8
module Util
  module VideoLinker
  
    def self.create_links
      video_dir = File.join(Rails.root, "public", "video")
      pasokaras = PasokaraFile.only(:id, :fullpath).all
      system("rm -rf #{File.join(video_dir, "*")}")

      pasokaras.each do |pasokara|
        if pasokara.flv? || pasokara.mp4?
          #subdir = File.join(video_dir, ((pasokara.id / 1000) * 1000).to_s)
          #Dir.mkdir(subdir) unless File.exist?(subdir)
          puts "#{pasokara.fullpath} => #{File.join(Rails.root, "public", pasokara.movie_path)}"
          system("ln -s \"#{pasokara.fullpath}\" #{File.join(Rails.root, "public", pasokara.movie_path)}")
        end
      end
    end
  end
end
