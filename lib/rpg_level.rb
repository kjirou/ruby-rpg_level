require 'rpg_level/version'

class RpgLevel
  attr_reader(:exp, :min_level, :necessary_exps)

  def initialize(min_level: 1)
    @exp = 0
    @min_level = min_level
    # Necessary exps from the @min_level
    @necessary_exps = []
  end

  def define_exp_table_from_array(necessary_exps)
    # TODO: integer >= 0 validation
    @necessary_exps = necessary_exps
    @necessary_exps.freeze
  end

  def define_exp_table(max_level)
    raise ArgumentError.new('max_level is less than min_level') if max_level < @min_level
    raise ArgumentError unless block_given?
    # TODO: How to convert the block to a proc?
    necessary_exps = generate_necessary_exps(max_level) {|info| yield(info)}
    define_exp_table_from_array(necessary_exps)
  end

  def max_level
    @min_level + @necessary_exps.length
  end

  def find_necessary_exp_by_level(level)
    return nil unless level.between?(@min_level, max_level)
    return 0 if level == @min_level
    @necessary_exps[level - @min_level - 1]
  end

  def calculate_total_necessary_exp(from_level, to_level)
    raise ArgumentError.new('from_level is greater than to_level') if from_level > to_level
    # TODO: Generalize the `between(min, max)` logic
    raise ArgumentError.new('from_level is out of range') unless from_level.between?(@min_level, max_level)
    raise ArgumentError.new('to_level is out of range') unless to_level.between?(@min_level, max_level)

    (from_level..to_level).inject(0) do |result, level|
      result + find_necessary_exp_by_level(level)
    end
  end

  def max_exp
    calculate_total_necessary_exp(@min_level, max_level)
  end

  private

  def generate_necessary_exps(max_level)
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
