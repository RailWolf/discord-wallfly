# frozen_string_literal: true
#
module WallFlyBot
  Q2_EMOJI = '<:q2:1116136339964969000>'

  # Some servers always have [CAMERA]WallFly[BZZZ], stooge1 or both returned.
  # Filter them out if that's the only "person" in the server.
  Q2_ACTIVE = %r{
           ^(?!
           .*ZIGBOT.*|
           .*\)\s(\[CAMERA\]WallFly|stooge1)(,\s(stooge1|\[CAMERA\]WallFly))?$
           )
           .*\(\s?\d{1,2}/\s?\d{1,2}\).*
           }x.freeze

  Q2_STATUS = lambda {
    status_lines = `"#{CFG.server_status}"`
    status_lines.each_line do |line|
      next unless line =~ Q2_ACTIVE

      GOTO.status_lines << "#{Q2_EMOJI} `#{line}`"
    end
  }

end
