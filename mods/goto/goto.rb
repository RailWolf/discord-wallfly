require_relative 'status'
require_relative 'bot_events'
require_relative 'protocols/q2/q2cmd3'
require_relative 'protocols/ql/quake_live'
require_relative 'protocols/q2/quake2'

module WallFlyBot

  # Goto
  class Goto
    attr_accessor :status_lines
    attr_reader :active

    def initialize
      @event = ''
      @counter = 0
      @status_lines = []
      @output = []
      @dmc = /^otog!?/i
      @upsd = /^!?oʇoƃ/i
      @q2_only = /^!?oʇoƃ|^otog!?/i
    end

    def re_init
      @counter = 0
      @status_lines = []
      @output = []
    end

    def run(event)
      @event = event
      Q2_STATUS.call
      QL_STATUS.call unless event.message.to_s =~ @q2_only
      count_players
      insert_header
      sort_by_score
      parse
      send
      re_init
    end

    # Get a total player count
    def count_players
      @status_lines.each do |line|
        num = line[/\(\s?\K\d{1,2}/].to_i
        @counter += num
      end
    end

    def sort_by_score
      @sorted_by_score = @status_lines.sort_by { |s| s[/\(\s?\K\d{1,2}/].to_i }
    end

    def insert_header
      pick = COLOR.color_pick
      header = "TASTYSPLEEN.NET AND FRIENDS ACTIVE QUAKE SERVERS | PLAYERS: #{@counter}"
      @output << COLOR.color_get(:"#{pick}1") + alternate_cmds(header) + COLOR.color_get(:"#{pick}2")
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
      @sorted_by_score.reverse.each do |line|
        line = alternate_cmds(line)
        @output << line
      end
    end

    def send
      @output.reverse! if @event.message.to_s =~ @upsd
      @output.each do |line|
        @event.respond line
      end
    end
  end
  GOTO = Goto.new
end
