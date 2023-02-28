#!/usr/bin/env ruby

# WallFly[BZZZ] Discord Bot
# 2022-2023 RailWolf
# railwolf@tastyspleen.net

require 'discordrb'
require_relative 'core/bot/bot_auth'
require_relative 'core/bot/bot_admin_cmds'
require_relative 'core/discord/colors'
require_relative 'core/flippy/flippy'
require_relative 'core/bot/bot_cfg'
load '../server-status/all-servers.cfg'
require_relative 'mods/goto/goto'
require_relative 'mods/wf_talk/wf_talk'

# BZZZ
module WallFlyBot

  begin
    BOT.run :async
    BOT.join
  rescue RestClient::ServerBrokeConnection
    puts 'Server Broke Connection'
    sleep 1
    retry
  rescue Net::OpenTimeout
    puts 'Open Timeout'
    sleep 1
    retry
  rescue RestClient::Exceptions::OpenTimeout
    puts 'Open Timeout Exception'
    sleep 1
    retry
  rescue Discordrb::Errors::MessageTooLong
    puts 'Character Limit Hit For Message'
  rescue Errno::ECONNRESET
    puts 'Connection Reset'
    sleep 1
    retry
  end
end
