module WallFlyBot

  # Goto
  class Goto

    def initialize(event)
      @event = event
      @counter = 0
      @status_lines = []
      @emoji = '<:q2:740942279501676585>'
      @dmc = /^otog!?/ix
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

    # Parse and send to Discord. If the cmd was otog! then reverse the line.
    def send
      @status_lines.each_line do |line|
        line.chop!
        case line
        when @activeheader
          line = "TASTYSPLEEN.NET AND FRIENDS ACTIVE QUAKE2 SERVERS | PLAYERS: #{@counter}"
          line = line.reverse.to_s if @event.message.to_s =~ @dmc
          pick = COLOR.color_pick
          @event.respond COLOR.color_get(:"#{pick}1") + line + COLOR.color_get(:"#{pick}2")
          @counter = 0
        when @active
          line = line.reverse if @event.message.to_s =~ @dmc
          @event.respond "#{@emoji} `#{line}`"
        end
      end
    end
  end
end
