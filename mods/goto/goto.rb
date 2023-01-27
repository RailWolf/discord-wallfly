module WallFlyBot

  # Goto
  class Goto

    def initialize(event)
      @event = event
      @counter = 0
      @status_lines = []
      @output = []
      @emoji = '<:q2:740942279501676585>'
      @dmc = /^otog!?/ix
      @upsd = /^!?oʇoƃ/ix
      @dspu = /^!?ƃoʇo/ix
      @activeheader = /.*ACTIVE_SERVERS.*/
      # Some servers always have [CAMERA]WallFly[BZZZ] or stooge1 returned, so filter them out if that's the only "person" in the server.
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
      parse
      send
    end

    # Dropping to shell to execute the 1.8.6 server-status.rb file
    def servstat
      @status_lines = `"#{CFG.server_status}"`
    end

    # Get a total player count ignoring filtered lines
    def count_players
      @status_lines.each_line do |line|
        if line =~ @active
          num = line[/\(\s?\K\d{1,2}/].to_i
          @counter += num
        end
      end
    end

    def alternate_cmds(line)
      case @event.message.to_s
      when @dmc
        line = line.reverse
      when @upsd
        line = line.downcase.flip
      when @dspu
        line = line.downcase.flip.reverse
      end
      line
    end

    # Parse and send to Discord. If the cmd was otog! then reverse the line.
    def parse
      @status_lines.each_line do |line|
        line.chop!
        case line
        when @activeheader
          line = "TASTYSPLEEN.NET AND FRIENDS ACTIVE QUAKE2 SERVERS | PLAYERS: #{@counter}"
          line = alternate_cmds(line)
          pick = COLOR.color_pick
          @output << COLOR.color_get(:"#{pick}1") + line + COLOR.color_get(:"#{pick}2")
          @counter = 0
        when @active
          line = alternate_cmds(line)
          @output << "#{@emoji} `#{line}`"
        end
      end
      @output.reverse! if @event.message.to_s =~ @upsd || @dspu
    end

    def send
      @output.each do |line|
        @event.respond line
      end
    end
  end
end
