# 2023 RailWolf
# QuakeLive Server Query For Goto

require 'socket'
require_relative 'quake_live_servers'
require_relative 'quake_live_query'

module WallFlyBot
  QL_STATUS = lambda {
    Fiber.set_scheduler(FiberScheduler.new)
    QL_SVS.each do |sv|
      FiberScheduler do
        Fiber.schedule { QuakeLiveQuery.new(sv) }
      end
    end
  }
end
