module WallFlyBot
  BOT.message(content: CFG.cmds_wf_talk, in: CFG.channels_wf_talk) do |event|
    wf_talk = WFTalk.new(event)
    wf_talk.go
  end
end
