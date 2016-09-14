require 'rpg_level/version'


class RpgLevel
  def initialize
    @min_level = 1
  end

  private

  def generate_necessary_exps(start_level: 1, max_level: 99)
    raise ArgumentError unless block_given?

    exps = []
    memo = {}

    (@min_level..max_level).map do |level|
      exp = if level <= start_level then
        0
      else
        yield({
          level: level,
          min_level: @min_level,
          start_level: start_level,
          max_level: max_level,
          exps: exps,
          memo: memo
        })
      end
      exps << exp
      exp
    end
  end
end
