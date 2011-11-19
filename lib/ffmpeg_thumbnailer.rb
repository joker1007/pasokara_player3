require "shellwords"

module FFmpegThumbnailer
  FFMPEG = `which ffmpeg`.chop

  def self.create(path, offset = 5)
    output = path.gsub(/\.[a-zA-Z0-9]+$/, ".jpg")
    system("#{FFMPEG}", "-ss", "#{offset}", "-vframes", "1", "-i", path, "-f", "image2", output)
  end
end
