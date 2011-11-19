require "shellwords"
require "open3"

module FFmpegInfo
  FFMPEG = `which ffmpeg`.chop

  def self.getinfo(input)
    video = {}
    audio = {}
    duration = 0
    stdin, stdout_and_stderr = *Open3.popen2e("#{FFMPEG} -i #{Shellwords.shellescape(input)}")
    stdout_and_stderr.each_line do |line|
      case line
      when /\s*Stream #\d\.\d.*?: Video: (.+?), (.+?), (.+?),/
        video[:codec] = $1
        video[:format] = $2
        video[:size] = $3
      when /\s*Stream #\d\.\d.*?: Audio: (.+?), (.+?), (.+?), (.+?)/
        audio[:codec] = $1
        audio[:rate] = $2.to_i
        audio[:channels] = $3
      when /Duration: (\d\d):(\d\d):(\d\d)\.(\d\d),/
        duration = $1.to_i * 3600 + $2.to_i * 60 + $3.to_i
      end
    end

    if video[:size]
      video[:size] =~ /(\d+)x(\d+)/
      video[:width] = $1.to_i
      video[:height] = $2.to_i
      video[:aspect] = sprintf("%1.4f", $1.to_f / $2.to_f)
    end

    {:video => video, :audio => audio, :duration => duration}
  end
end
