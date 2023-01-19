#!/usr/bin/env ruby

# WallFly[BZZZ] Discord Bot
# 2022-2023 RailWolf
# railwolf@tastyspleen.net

# Bot
require 'discordrb'
require_relative 'core/bot/bot_cfg'
require_relative 'core/bot/bot_auth'
require_relative 'core/discord/colors'
# Mods
load '../server-status/all-servers.cfg'
require_relative 'mods/goto/goto'
require_relative 'mods/status/status'
require_relative 'q2cmd3'
require 'flippy'

# WallFly Bot
module WallFlyBot

  BOT = Discordrb::Bot.new token: AUTH.token
  begin

    BOT.message(content: CFG.cmds_goto, in: CFG.channels_goto) do |event|
      goto = Goto.new(event)
      goto.go
    end

    BOT.message(content: CFG.cmds_status, in: CFG.channels_status) do |event|
      status = Status.new(event)
      status.go
    end

    BOT.message(content: '!wfreload', author: 'RailWolf#4617') do |event|
      load CFG.server_info
      event.respond 'Server List Reloaded'
    end

    BOT.run
  rescue RestClient::ServerBrokeConnection
    retry
  rescue Net::OpenTimeout
    retry
  rescue RestClient::Exceptions::OpenTimeout
    retry
  rescue Discordrb::Errors::MessageTooLong
    retry
  rescue Errno::ECONNRESET
    retry
  end
end
