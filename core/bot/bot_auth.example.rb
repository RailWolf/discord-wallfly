# Copy to bot_auth.rb

module WallFlyBot
  BOT_ADMIN = 'User#0000'.freeze

  # Bot Token
  class BotAuth
    attr_reader :token, :api_token

    def initialize
      @token = 'token'
      @api_token = 'Bot token'
    end
  end
  AUTH = BotAuth.new
  BOT = Discordrb::Commands::CommandBot.new token: AUTH.token
end
