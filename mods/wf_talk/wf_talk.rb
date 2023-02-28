require_relative 'bot_events'

module WallFlyBot

  # Talk as wallfly in discord
  # !wf #channel text
  class WFTalk

    def initialize(event)
      @event = event
      @msg = event.message.to_s.split(/\s/, 3)
    end

    def go
      BOT.send_message(@msg[1].gsub(/[^\d+]/, '').to_i, @msg[2])
    rescue RestClient::NotFound
      @event.respond 'Invalid Channel Name'
    rescue RestClient::BadRequest
      @event.respond 'Bad Request. Check syntax.'
    end
  end
end
