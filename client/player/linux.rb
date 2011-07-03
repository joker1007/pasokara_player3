module Player
  module Linux
    
    def launch_player(cmd)
      pid = fork {
        exec(cmd)
      }

      th = Process.detach(pid)
      th.join
    end
  end
end
