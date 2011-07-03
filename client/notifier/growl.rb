# _*_ coding: utf-8 _*_
require "rubygems"
require "ruby-growl"
require "singleton"

module Notifier
  class GrowlNotifier
    include Singleton

    def initialize
      begin
        @@growl = Growl.new "127.0.0.1", "pasokara_player", ["Queue", "Play"]
      rescue Exception
        @@growl = nil
        puts $!
        puts $@
        puts "NoGrowl"
      end
    end

    def play_notify(name)
      begin
        if @@growl
          @@growl.notify "Play", "Playing", name
        end
      rescue Exception
        puts "Notify Failed"
        puts $!
        puts $@
      end
    end

    def queue_notify(name)
      begin
        if @@growl
          @@growl.notify "Queue", "Queueing", name
        end
      rescue Exception
        puts "Notify Failed"
        puts $!
        puts $@
      end
    end
  end
end
