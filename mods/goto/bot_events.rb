module WallFlyBot
  BOT.message(content: CFG.cmds_goto, in: CFG.channels_goto) { |event| WFQ.queue << event }
  BOT.message(content: CFG.cmds_status, in: CFG.channels_status) { |event| WFQ.queue << event }
end
