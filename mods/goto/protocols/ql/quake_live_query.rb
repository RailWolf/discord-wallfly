# 2023 RailWolf

module WallFlyBot
  QL_EMOJI = '<:qlive:1116136594982838312>'.freeze
  QL_PKT_HEADER = [0xff, 0xff, 0xff, 0xff].pack('C*')
  A2S_INFO = "TSource Engine Query#{[0x00].pack('C*')}".freeze
  A2S_PLAYER = [0x55].pack('C*')
  A2S_RULES = [0x56].pack('C*')
  CHALLENGE_REQ = [0x00, 0x00, 0x00, 0x00].pack('C*')
  PLAYER_STRUCT = Struct.new(:name, :score)

  class QuakeLiveQuery

    def initialize(sv)
      @sv = sv
      @snd_response = ''
      # @player = PLAYER_STRUCT.new
      run
    end

    def run
      @sock = UDPSocket.open
      request_info
      request_rules
      request_players
      @sock.close
    end

    def send(request)
      udp_recv_timeout = 0.5
      begin
        @sock.send(request, 0, @sv.host, @sv.port)
        if select([@sock], nil, nil, udp_recv_timeout)
          begin
            Timeout.timeout(udp_recv_timeout) do
              @snd_response = @sock.recvfrom(1400)
            end
          rescue Timeout::Error
            @snd_response = nil
            warn "qlcmd: Timeout::Error in sock.recvfrom ! #{@sv.host}:#{@sv.port}"
          end
        end
      rescue IOError, SystemCallError, SocketError
        puts 'Error In Send'
      end
      @snd_response.nil? ? nil : @snd_response
    end

    def request_challenge
      request = QL_PKT_HEADER + A2S_RULES + CHALLENGE_REQ
      response = send(request)
      return if response.nil?

      response[0].unpack1('H*').gsub(/^f{8}.{2}/, '')
    end

    def request_info
      challenge = request_challenge
      request = QL_PKT_HEADER + A2S_INFO + [challenge].pack('H*')
      response = send(request)
      return nil if response.nil?

      @sv.current_map = response[0].split(/\x00/, 3)[1]
      # puts 'Map: ' + @sv.current_map # response[0].split(/\x00/, 3)[1]
    end

    def request_rules
      challenge = request_challenge
      request = QL_PKT_HEADER + A2S_RULES + [challenge].pack('H*')
      response = send(request)
      return nil if response.nil?

      svr_info = response[0].split(/\x00/)
      svr_info.each_with_index do |sv, i|
        # puts "request_rules: " + sv
        if sv =~ /sv_maxclients/i
          @sv.max_clients = svr_info[i + 1]
          # puts 'Max Clients: ' + @sv.max_clients
        end
      end
    end

    # Team, Name, Time, Score, Elo
    # This isn't a full decoding of the return, just enough for goto
    #
    def request_players
      challenge = request_challenge
      request = QL_PKT_HEADER + A2S_PLAYER + [challenge].pack('H*')
      response = send(request)
      return nil if response.nil?

      # puts "Raw Response: " + response[0]
      response = response[0].unpack('H*')
      clients = response.to_s[/f{8}44.{2}/][-2..]
      # puts 'Clients: ' + "0x#{clients}".hex.to_s
      @sv.clients = "0x#{clients}".hex
      return unless @sv.clients.positive?

      players_a = []
      players = response.to_s.split(/00/)
      players.each_with_index do |p, i|
        next unless p =~ /ffffffff44|4[3-6]$/

        # Force encoding on here for now. Sometimes it gets rejected in discordrb with invalid utf-8 character.
        name = [players[i + 1]].pack('H*').to_s.gsub(/\^\d/, '').force_encoding("ISO-8859-1").encode("UTF-8")
        score = players[i + 2].to_i(16)
        players_a << PLAYER_STRUCT.new(name, score) unless name.empty?
      end
      players_by_score = players_a.sort_by { |cl| -cl.score }

      out_players = players_by_score.collect(&:name)
      out = format("[%-#{@sv.zone.length}s] %-#{@sv.nick.length}s %-#{@sv.current_map.length}s (%2d/%2d) ",
                   @sv.zone, @sv.nick.upcase, @sv.current_map, @sv.clients, @sv.max_clients)
      out << out_players.join(', ')
      GOTO.status_lines << "#{QL_EMOJI} `#{out}`"
    end
  end
end
