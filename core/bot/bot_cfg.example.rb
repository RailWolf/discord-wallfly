module WallFlyBot

  class BotConfig
    attr_reader :channels_goto, :channels_status, :channels_wf_talk,
                :cmds_goto, :cmds_status, :cmds_wf_talk,
                :server_status, :server_info

    def initialize
      initialize_goto
      initialize_channels
      initialize_cmds
    end

    def initialize_goto
      # Goto file for obtaining server status
      @server_status = '../server-status/server-status.rb'
      # Contains the servers struct for server info
      @server_info = '../server-status/all-servers.cfg'
    end

    def initialize_channels
      @channels_goto = %w[#goto #live-test]
      @channels_status = %w[#goto #live-test]
      @channels_wf_talk = [0000000000, '#channel']
    end

    def initialize_cmds
      @cmds_goto = /^!?goto|^otog!?|^ƃoʇo|^oʇoƃ/i
      @cmds_status = /^!?frags\s.*|^!?status\s.*|^!?scores?\s.*/i
      @cmds_wf_talk = /^!wf\s.*/ix
    end
  end
  CFG = BotConfig.new
end
