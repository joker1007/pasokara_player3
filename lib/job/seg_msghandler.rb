require 'open-uri'

STDOUT.sync = true

@m3u8_file = ARGV.shift
@http_prefix = ARGV.shift
@file_prefix = ARGV.shift
@duration = ARGV.shift || 10
@dir = File.dirname(File.expand_path(__FILE__))

@segmenter_wait = 1

File.delete @m3u8_file if File.exist?(@m3u8_file)

@first = true
def write_m3u8 str
  unless @first
    unless test('e', @m3u8_file)
      puts "segmenter_handler: #{@m3u8_file} is not exist"
      return nil
    end
  else
    @first = false
  end
  File.open @m3u8_file, 'a' do |fd|
    fd.flock File::LOCK_EX
    fd.write str
  end
end

str = <<"END"
#EXTM3U
#EXT-X-TARGETDURATION:#{@duration}
#EXT-X-MEDIA-SEQUENCE:1
END

puts 'segmenter_handler: started'

while line = gets
  if line =~ /segmenter: (\d+), (\d+), (\d+), (.+?)(, (-?\d+\.\d*))?$/
    index = $2.to_i
    get_duration = `ffmpeg -i "#{@file_prefix}-#{sprintf('%05d', index)}.ts" 2>&1 | ruby #{@dir}/get_duration.rb`
    duration = get_duration.to_f.round
    duration = @duration if duration < 0.0    
    if index < @segmenter_wait
      str << "#EXTINF:#{duration},\n"
      str << @http_prefix + sprintf('%05d',index) + ".ts\n"
    elsif index == @segmenter_wait
      puts 'segmenter_handler: ready'
      str << "#EXTINF:#{duration},\n"
      str << @http_prefix + sprintf('%05d',index) + ".ts\n"
      write_m3u8 str
      str = ''
    else
      tmp = "#EXTINF:#{duration},\n"
      tmp << @http_prefix + sprintf('%05d',index) + ".ts\n"
      write_m3u8 tmp
    end
  end 
  puts "segmenter: #{line}"
end

write_m3u8 str unless str.empty?

write_m3u8 "#EXT-X-ENDLIST\n"

puts 'segmenter_handler: finished'

