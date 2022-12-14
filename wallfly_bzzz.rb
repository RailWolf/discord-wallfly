require 'discordrb'
load 'bot_cfg.rb'
load $server_info

# WallFly[BZZZ] Discord Bot
# 2022 RailWolf
#
# This requires a few pieces from dorkbuster to operate. server-info.cfg and all-servers.cfg must be configured.
# q2cmd.rb and all-servers.cfg need symbolic links in the bot's cwd
# Set discord token in bot_cfg.rb. The paths in bot_cfg.rb shouldn't change unless you've changed the folder
# structure for some reason :P
# Note server-status.rb currently uses Ruby 1.8.6 and WallFly[BZZZ] Discord Bot uses 3.1.0

# These aren't all the colors in Discord markdown, but these were good to work with.
# Picking random color for the header each time.
class DiscordColors
  
  def initialize
    @colors = {
      red1: "```diff\n-= ",
      red2: " =-\n```",
      green1: "```diff\n+ ",
      green2: " +\n```",
      orange1: "```css\n[- ",
      orange2: " -]\n```",
      yellow1: "```fix\n",
      yellow2: "\n```",
      blue1: "```ini\n[ ",
      blue2: " ]\n```",
      #none1: '`',
      #none2: '`'
    }
  end

  def pickcolor
    @colors.keys.sample.to_s.gsub(/\d/, '')
  end

  def getcolor(c)
    @colors[c]
  end
end

class Goto
  attr_reader :cmd, :status_lines

  def initialize
    @counter = 0
    @status_lines = []
    @emoji = '<:q2:740942279501676585>'
    @cmd = /^!goto|^otog!/ix
    @dmc = /^otog!/ix
    @activeheader = /.*ACTIVE_SERVERS.*/
    # Some servers always have [CAMERA]WallFly[BZZZ] or stooge1 returned, so filter them out if that's the only "person" in the server.
    # Should probably filter [CAMERA]WallFly[BZZZ]$ and stooge1$ in the server-status file instead of here so that it ignores them in quake2 as well.
    @active =
      %r{
         ^(?!
         .*ZIGBOT.*|
         .*\)\s\[CAMERA\]WallFly$|
         .*\)\sstooge1$
         )
         .*\(\s?\d{1,2}/\s?\d{1,2}\).*
         }x
  end

  # Dropping to shell to execute the 1.8.6 server-status.rb file
  def servstat
    @status_lines = `#{$server_status}`
  end

  # Get a total player count ignoring filtered lines
  def get_player_count
    @status_lines.each_line do |line|
      if line =~ @active
        num = line[/\(\s?\K\d{1,2}/].to_i
        @counter += num
      end
    end
  end


  # Parse and send to Discord. If the cmd was otog! then reverse the line.
  def send(event, color)
    @status_lines.each_line do |line|
      line.chop!
      case line
      when @activeheader
        line = "TASTYSPLEEN.NET AND FRIENDS ACTIVE QUAKE2 SERVERS | PLAYERS: #{@counter}"
        line = line.reverse.to_s if event.message.to_s =~ @dmc
        pick = color.pickcolor
        event.respond color.getcolor(:"#{pick}1") + line + color.getcolor(:"#{pick}2")
        @counter = 0
      when @active
        line = line.reverse if event.message.to_s =~ @dmc
        event.respond "#{@emoji} `#{line}`"
      end
    end
  end

end

begin
  goto = Goto.new
  color = DiscordColors.new
  bot = Discordrb::Bot.new token: $discord_token

  bot.message(content: goto.cmd) do |event|
    goto.servstat
    goto.get_player_count
    goto.send(event, color)
  end

  bot.run
rescue RestClient::ServerBrokeConnection
  retry
rescue Net::OpenTimeout
  retry
rescue RestClient::Exceptions::OpenTimeout
  retry
rescue RestClient::BadRequest
  retry
rescue Discordrb::Errors::MessageTooLong
  retry
rescue RestClient::InternalServerError
  retry
rescue Errno::ECONNRESET
  retry
end
