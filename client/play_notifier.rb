require 'drb/drb'

client = DRbObject.new_with_uri("druby://localhost:12346")
client.playing = false
