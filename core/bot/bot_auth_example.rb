module WallFlyBot

  # Bot Token and any additional logins such as database
  class BotAuth
    attr_reader :token

    def initialize
      @token = 'token'
    end
  end
  AUTH = BotAuth.new
end
