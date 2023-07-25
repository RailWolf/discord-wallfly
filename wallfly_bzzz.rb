#!/usr/bin/env ruby

# WallFly[BZZZ] Discord Bot
# 2022-2023 RailWolf
# railwolf@tastyspleen.net

# require 'rubygems'
require 'discordrb'
require 'fiber_scheduler'
require_relative 'core/bot/bot_auth'
require_relative 'core/bot/bot_admin_cmds'
require_relative 'core/discord/colors'
require_relative 'core/flippy/flippy'
require_relative 'core/bot/queue'
require_relative 'core/bot/bot_cfg'
load '../server-status/all-servers.cfg'
require_relative 'mods/goto/goto'
require_relative 'mods/wf_talk/wf_talk'

# BZZZ
module WallFlyBot
  begin
     puts Discordrb::VERSION
    BOT.run :async
    BOT.join
  end
end
