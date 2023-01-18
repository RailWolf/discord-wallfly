module WallFlyBot

  # Server Status
  class Status

    def initialize(event)
      @event = event
      @status_str = []
      @cmd = /^!?frags\s.*|^!?status\s.*|^!?scores?\s.*/i
      @serverstruct = ''
      @scores = []
      @sorted_by_score = []
      @dead = false
      @counter = 0
      # TODO: filter wallfly
      @wallfly = /WallFly\[BZZZ\]/x
    end

    def go
      server
      q2status
      count_scores
    end

    # Check if the server nick given by the user matches a known server in all-servers
    def server
      servernick = @event.message.to_s.gsub(/^!?frags\s|^!?status\s|^!?scores?\s/i, '')
      return(@dead = true) unless ServerInfo.server_info.include? servernick

      @serverstruct = ServerInfo.server_info[servernick]
    end

    # Send status command to server
    def q2status
      return(@event.respond 'Server Not Found') if @dead

      @status_str = q2cmd(@serverstruct.gameip, @serverstruct.gameport, 'status')
      return unless @status_str.nil?

      @event.respond 'No Response From Server'
      @dead = true
    end

    # Get a total score count
    def count_scores
      return if @dead

      @status_str.to_s.split(/\n/).each do |line|
        if line !~ @wallfly
          num = line[/^\d{1,4}/].to_i
          @counter += num
        end
      end
      parse_status_str
    end

    # Ready the output for Discord.
    def parse_status_str
      lines = @status_str.to_s.split(/\n/)
      lines.shift # drop "print" line
      lines.each do |client_line|
        client_line.strip!
        next unless client_line =~ /(\d+)\s+(\d+)\s+"(.*)"/

        score, ping, name = $1.ljust(5, ' '), $2.ljust(4, ' '), $3
        @scores << "`#{score} | #{ping} | #{name}`"
      end
      sort
    end

    # Sort the output by score, highest to lowest.
    def sort
      @sorted_by_score = @scores.sort_by { |f| f[1..].to_i }.reverse
      send
    end

    # Off you go
    def send
      @event.respond "#{COLOR.color_get(:yellow1)}  #{@serverstruct.nick}  >>  #{@serverstruct.desc} | #{@serverstruct.gameip}:#{@serverstruct.gameport} | Total Score: #{@counter}#{COLOR.color_get(:yellow2)}"
      @sorted_by_score.empty? ? (@event.respond '`No Active Players`') : (@event.respond '`Score | Ping | Name`')
      @event.respond(@sorted_by_score.join("\n")) unless @sorted_by_score.empty?
    end
  end
end
