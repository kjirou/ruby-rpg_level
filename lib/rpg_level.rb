require 'rpg_level/version'


class RpgLevel
  attr_reader(:min_level, :necessary_exps)

  def initialize
    @min_level = 1

    # Necessary exps from the MIN_LEVEL
    @necessary_exps = []
  end

  #def define_exp_table(start_level: 1, max_level: 99)
  #  raise ArgumentError unless block_given?
  #  @necessary_exps = generate_necessary_exps(start_level, max_level) {|data| yield(data)}
  #end

  def max_level
    @min_level + @necessary_exps.length
  end

  private

  def generate_necessary_exps(max_level)
    raise ArgumentError 'max_level less than min_level' if max_level < @min_level

    exps = []
    memo = {}

    ((@min_level + 1)..max_level).map do |level|
      exp = yield({
        level: level,
        min_level: @min_level,
        max_level: max_level,
        exps: exps,
        memo: memo
      })
      exps << exp
      exp
    end
  end
end
