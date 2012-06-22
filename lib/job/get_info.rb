# coding: utf-8
video = Hash.new{|h,k| h[k]=""}
audio = Hash.new{|h,k| h[k]=""}

while line = gets
  begin
    #p [:msg,line]
    case line
    when /\s*Stream #\d[:\.]\d.*?: Video: (.+?), (.+?), (.+?),/
      video['codec'] = $1
      video['format'] = $2
      video['rez'] = $3
    when /\s*Stream #\d[:\.]\d.*?: Audio: (.+?), (.+?), (.+?), (.+?)/
      audio['codec'] = $1
      audio['rate'] = $2
      audio['channels'] = $3
    else
    #  p [:msg,line]
    end
  rescue
    next
  end
end

if video['rez']
  video['rez'] =~ /(\d+)x(\d+)/
  video['width'] = $1.to_i
  video['height'] = $2.to_i
  video['aspect'] = sprintf '%1.4f',$1.to_f / $2.to_f
end
#p video
#p audio
puts video['aspect']
