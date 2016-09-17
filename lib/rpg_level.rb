require 'rpg_level/version'


class RpgLevel
  attr_reader(:min_level, :necessary_exps)

  def initialize(min_level: 1)
    @min_level = min_level

    # Necessary exps from the @min_level
    @necessary_exps = []
  end

  def define_exp_table_from_array(necessary_exps)
    @necessary_exps = necessary_exps
    @necessary_exps.freeze
  end

  def define_exp_table(max_level)
    raise ArgumentError unless block_given?
    # TODO: to &block
    necessary_exps = generate_necessary_exps(max_level) {|info| yield(info)}
    define_exp_table_from_array(necessary_exps)
  end

  def max_level
    @min_level + @necessary_exps.length
  end

  private

  def generate_necessary_exps(max_level)
    raise ArgumentError.new('max_level is less than min_level') if max_level < @min_level

    generated_exps = []
    memo = {}

    ((@min_level + 1)..max_level).map do |level|
      exp = yield({
        level: level,
        min_level: @min_level,
        max_level: max_level,
        generated_exps: generated_exps,
        memo: memo
      })
      generated_exps << exp
      exp
    end
  end
end
