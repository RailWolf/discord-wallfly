module WallFlyBot

  # These aren't all the colors in Discord markdown, but these were good to work with.
  # Recent discord update broke some of these.
  # TODO: Go through and relabel/prune
  class DiscordColors

    def initialize
      @colors = {
        red1: "```diff\n-= ",
        red2: " =-\n```",
        green1: "```diff\n+ ",
        green2: " +\n```",
        orange1: "```css\n[- ",
        orange2: " -]\n```",
        yellow1: "```fix\n",
        yellow2: "\n```",
        blue1: "```ini\n[ ",
        blue2: " ]\n```"
      }
    end

    # Pick a random color
    def color_pick
      @colors.keys.sample.to_s.gsub(/\d/, '')
    end

    # Return the value for a color
    def color_get(c)
      @colors[c]
    end
  end
  COLOR = DiscordColors.new
end
