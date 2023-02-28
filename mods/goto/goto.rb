require_relative 'status'
require_relative 'bot_events'
require_relative 'q2cmd3'

module WallFlyBot

  # Goto
  class Goto

    def initialize(event)
      @event = event
      @counter = 0
      @status_lines = []
      @output = []
      @emoji = '<:q2:740942279501676585>'
      @dmc = /^otog!?/i
      @upsd = /^!?oʇoƃ/i
      @activeheader = "TASTYSPLEEN.NET AND FRIENDS ACTIVE QUAKE2 SERVERS | PLAYERS: #{@counter}"
      # Some servers always have [CAMERA]WallFly[BZZZ], stooge1 or both returned.
      # Filter them out if that's the only "person" in the server.
      @active =
        %r{
           ^(?!
           .*ZIGBOT.*|
           .*\)\s(\[CAMERA\]WallFly|stooge1)(,\s(stooge1|\[CAMERA\]WallFly))?$
           )
           .*\(\s?\d{1,2}/\s?\d{1,2}\).*
           }x
    end

    def go
      servstat
      count_players
      insert_header
      parse
      send
    end

    # Dropping to shell to execute the 1.8.6 server-status.rb file
    def servstat
      @status_lines = `"#{CFG.server_status}"`
    end

    # Get a total player count
    def count_players
      @status_lines.each_line do |line|
        next unless line =~ @active

        num = line[/\(\s?\K\d{1,2}/].to_i
        @counter += num
      end
    end

    def insert_header
      pick = COLOR.color_pick
      @output << COLOR.color_get(:"#{pick}1") + alternate_cmds(@activeheader) + COLOR.color_get(:"#{pick}2")
    end

    def alternate_cmds(line)
      case @event.message.to_s
      when @dmc
        line = line.reverse
      when @upsd
        line = line.downcase.flip
      end
      line
    end

    def parse
      @status_lines.each_line do |line|
        line.chop!
        next unless line =~ @active

        line = alternate_cmds(line)
        @output << "#{@emoji} `#{line}`"
      end
    end

    def send
      @output.reverse! if @event.message.to_s =~ @upsd
      @output.each do |line|
        @event.respond line
      end
    end
  end

end
