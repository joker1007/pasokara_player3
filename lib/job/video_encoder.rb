module Job
  class VideoEncoder
    @queue = :pp3

    def self.perform(id, host, type)
      pasokara = PasokaraFile.find(id)
      pasokara.encoding = true
      pasokara.save
      case type
      when "stream"
        stream_encode(pasokara, host)
      when "safari"
        safari_encode(pasokara)
      when "webm"
        webm_encode(pasokara)
      end
      pasokara.encoding = false
      pasokara.save
    end

    def self.stream_encode(pasokara, host)
      segmenter_duration = "5"

      input_file = pasokara.fullpath
      aspect = `#{Rails.root}/lib/job/get_info.sh "#{input_file}"`.chomp
      system("#{Rails.root}/lib/job/video_encoder.sh", input_file, "#{Rails.root}/public/video", aspect.to_s, aspect.to_s, segmenter_duration, pasokara.encode_prefix(:stream), "http://#{host}/video")
    end

    def self.safari_encode(pasokara)
      input_file = pasokara.fullpath
      aspect = `#{Rails.root}/lib/job/get_info.sh "#{input_file}"`.chomp
      system("#{Rails.root}/lib/job/safari_encoder.sh", input_file, "#{Rails.root}/public/video", aspect.to_s, aspect.to_s, pasokara.encode_prefix(:safari))
    end

    def self.webm_encode(pasokara)
      input_file = pasokara.fullpath
      aspect = `#{Rails.root}/lib/job/get_info.sh "#{input_file}"`.chomp
      system("#{Rails.root}/lib/job/webm_encoder.sh", input_file, "#{Rails.root}/public/video", aspect.to_s, aspect.to_s, pasokara.encode_prefix(:webm))
    end
  end
end

