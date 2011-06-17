hour = 0
min = 0
sec = 0
milisec = 0
while line = gets
  if line =~ /\s*Duration: (\d\d):(\d\d):(\d\d)\.(\d\d).*/
    hour = $1.to_f
    min = $2.to_f
    sec = $3.to_f
    milisec = $4.to_f
  end
end

duration = ( hour * 60 * 60 ) + ( min * 60 ) + sec + ( milisec/100 )
puts sprintf('%.2f', duration)
