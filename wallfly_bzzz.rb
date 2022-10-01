require 'discordrb'
load 'bot_cfg.rb'
load $server_info

# WallFly[BZZZ] Discord Bot
# 2022 RailWolf
#
# Currently has Goto plus Magic 8 Ball
# This requires a few pieces from dorkbuster to operate. server-info.cfg and all-servers.cfg must be configured.
# q2cmd.rb and all-servers.cfg need symbolic links in the bot's cwd
# # Set discord token in bot_cfg.rb. The paths in bot_cfg.rb shouldn't change unless you've changed the folder
# structure for some reason :P
# Note server-status.rb currently uses Ruby 1.8.6 and WallFly[BZZZ] Discord Bot uses 3.1.0
#

class DiscordColors
 # These aren't all the colors in Discord markdown, but these were good to work with.
 # Only using orange right now for this project, but added them all to a class in case of future additions. Random header colors?
  def initialize
    @colors = {
      red1: "```diff\n-= ",
      red2: " =-\n```",
      green1: "```diff\n+",
      green2: "\n```",
      orange1: "```css\n[- ",
      orange2: " -]\n```",
      yellow1: "```fix\n",
      yellow2: "\n```",
      blue1: "```ini\n[",
      blue2: "\n```",
      none1: '`',
      none2: '`'
    }
  end

  def getcolor(c)
    @colors[c]
  end
end

class MagicBall
  attr_reader :answers, :cmd, :cmdok

  def initialize
    @cmd = /!8ball.*/i
    @cmdok = /^!8ball\s.*/i
    @answers = ['It is certain', 'It is decidedly so',
                'Without a doubt', 'Yes, definitely',
                'You may rely on it', 'As I see it, yes',
                'Most likely', 'Outlook good',
                'Signs point to yes', 'Yes',
                'Reply hazy, try again', 'Ask again later',
                'Better not tell you now',
                'Cannot predict now',
                'Concentrate and ask again', "Don't bet on it",
                'My reply is no', 'My sources say no',
                'Outlook not so good', 'Very doubtful',
                'I don\'t think so, Dave'
               ]
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
    @active = /.*\(\s?\d{1,2}\/\s?\d{1,2}\).*/
  # Some servers always have [CAMERA]WallFly[BZZZ] or stooge1 returned, so filter them out if that's the only "person" in the server.
  # Should probably filter [CAMERA]WallFly[BZZZ]$ and stooge1$ in the server-status file instead of here so that it ignores them in quake2 as well.
    @filter =
      /
         \[CAMERA\]WallFly$ |
         stooge1$ |
         .*ZIGBOT.*
      /x
  end

  # Dropping to shell to execute the 1.8.6 server-status.rb file
  def servstat
    @status_lines = `#{$server_status}`
  end

  # Get a total player count ignoring filtered lines
  def get_player_count(status_lines)
    status_lines.each_line do |line|
      if line =~ @active && line !~ @filter
        num = line[/\(\s?\d{1,2}/].delete('^[0-9]').to_i
        @counter += num
    end
    end
  end

  # Parse and send to Discord. If the cmd was otog! then reverse the line.
  def send(event, color)
    @status_lines.each_line do |line|
      line.chop!
      if line =~ @activeheader
        line = line.gsub(@activeheader, "TASTYSPLEEN.NET AND FRIENDS ACTIVE QUAKE2 SERVERS | PLAYERS: #{@counter}")
        line = line.reverse if event.message.to_s =~ @dmc
        event.respond color.getcolor(:orange1) + line.to_s + color.getcolor(:orange2)
        @counter = 0
      elsif line =~ @active && line !~ @filter
        line = line.reverse if event.message.to_s =~ @dmc
        event.respond "#{@emoji} `#{line}`"
      end
    end
 end

 end

begin
  goto = Goto.new
  color = DiscordColors.new
  magicball = MagicBall.new
  bot = Discordrb::Bot.new token: $discord_token

  bot.message(content: magicball.cmd) do |event|
    if event.message.to_s =~ magicball.cmdok
      event.respond magicball.answers.sample.to_s
    else
      event.respond 'Use !8ball <question>'
    end
  end

  bot.message(content: goto.cmd) do |event|
    goto.servstat
    goto.get_player_count(goto.status_lines)
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
