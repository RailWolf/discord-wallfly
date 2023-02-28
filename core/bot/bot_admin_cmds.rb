module WallFlyBot

  BOT.message(content: '!wfreload', author: BOT_ADMIN) do |event|
    load CFG.server_info
    event.respond 'BZZZ!'
  end

  BOT.message(content: '!exit', author: BOT_ADMIN) { BOT.stop }
end
