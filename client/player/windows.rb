require 'win32/process'


module Player
  module Win
    
    include Windows::Synchronize
    include Windows::Process
    include Windows::Handle

    def launch_player(cmd)
      pi = Process.create("app_name" => cmd)
      handle = OpenProcess(PROCESS_ALL_ACCESS, 0, pi.process_id)
      until WaitForSingleObject(handle, 0) == WAIT_OBJECT_0
        sleep 1
      end
      CloseHandle(handle)
    end
  end
end
