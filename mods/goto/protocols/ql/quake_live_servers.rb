# frozen_string_literal: true

module WallFlyBot
  SERVER_STRUCT = Struct.new(:host, :port, :nick, :zone, :current_map, :clients, :max_clients)
  MK_SV = ->(**sv) { SERVER_STRUCT.new(sv[:host], sv[:port], sv[:nick], sv[:zone]) }

  # ZONES
  TASTY = 'TASTY'

  # Server hosts
  PHOBOS = '23.227.169.187'
  MADHOUSE = '108.62.106.47'
  MADHOUSE_PORT = 27961
  DIK = '192.223.24.156'
  DIK_PORT = 27961
  CHI = '172.245.253.202'
  CHI_PORT = 27966
  PILL = '38.128.66.97'
  PILL_PORT = '27960'

  QL_SVS = [
    MK_SV[host: PHOBOS, port: 27960, nick: 'ql-ctf', zone: TASTY],
    MK_SV[host: PHOBOS, port: 27961, nick: 'ql-ca', zone: TASTY],
    MK_SV[host: PHOBOS, port: 27962, nick: 'ql-ffa', zone: TASTY],
    MK_SV[host: PHOBOS, port: 27963, nick: 'ql-dual', zone: TASTY],
    MK_SV[host: PHOBOS, port: 27964, nick: 'ql-tdm', zone: TASTY],
    MK_SV[host: MADHOUSE, port: MADHOUSE_PORT, nick: 'ql-mad-chi', zone: 'MADHOUSE'],
    MK_SV[host: DIK, port: DIK_PORT, nick: 'ql-dik', zone: 'DIK'],
    MK_SV[host: CHI, port: 27963, nick: 'ql-chi-3', zone: 'CHI'],
    MK_SV[host: CHI, port: 27964, nick: 'ql-chi-4', zone: 'CHI'],
    MK_SV[host: CHI, port: 27966, nick: 'ql-chi-6', zone: 'CHI']
  ].freeze
end
