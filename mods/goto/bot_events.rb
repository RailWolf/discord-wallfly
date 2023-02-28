module WallFlyBot

  BOT.message(content: CFG.cmds_goto, in: CFG.channels_goto) do |event|
    goto = Goto.new(event)
    goto.go
  end

  BOT.message(content: CFG.cmds_status, in: CFG.channels_status) do |event|
    status = Status.new(event)
    status.go
  end
end
