# Copy to bot_cfg.rb

module WallFlyBot

  # Channels, commands and what not
  class BotConfig
    attr_reader :channels_goto, :channels_status, :cmds_goto, :cmds_status, :server_status, :server_info

    def initialize
      # Goto file for obtaining server status
      @server_status = '../server-status/server-status.rb'
      # Contains the servers struct for matching nicknames to IPs
      @server_info = '../server-status/all-servers.cfg'
      # Channels
      @channels_goto = %w[#goto #roses-bounce-house #test #live-test]
      @channels_status = %w[#goto #roses-bounce-house #test #live-test]
      # Commands
      @cmds_goto = /^!?goto|^otog!?/ix
      @cmds_status = /^!?frags\s.*|^!?status\s.*|^!?scores?\s.*/i
    end
  end
  CFG = BotConfig.new
end
