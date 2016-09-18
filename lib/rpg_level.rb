require 'rpg_level/version'

class RpgLevel
  CLEARED_CACHED_CURRENT_LEVEL_STATUS = nil

  attr_reader(:exp, :min_level, :necessary_exps)

  def initialize(min_level: 1)
    @exp = 0
    @min_level = min_level
    # Necessary exps from the @min_level
    @necessary_exps = []
    # A cache of the #generate_status_of_current_level calculation
    # It is too heavy for access to #level_status like a static value
    @cached_current_level_status = CLEARED_CACHED_CURRENT_LEVEL_STATUS
  end

  def define_exp_table_from_array(necessary_exps)
    necessary_exps.each do |v|
      raise ArgumentError.new('some of necessary_exps are not a integer') unless v.is_a?(Integer)
      raise ArgumentError.new('some of necessary_exps are less than 0') if v < 0
    end

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

  def is_allowed_level?(level)
    level.between?(@min_level, max_level)
  end

  def find_necessary_exp_by_level(level)
    return nil unless is_allowed_level?(level)
    return 0 if level == @min_level
    @necessary_exps[level - @min_level - 1]
  end

  def calculate_total_necessary_exp(from_level, to_level)
    raise ArgumentError.new('from_level is greater than to_level') if from_level > to_level
    raise ArgumentError.new('from_level is out of range') unless is_allowed_level?(from_level)
    raise ArgumentError.new('to_level is out of range') unless is_allowed_level?(to_level)

    (from_level..to_level).inject(0) do |result, level|
      result + find_necessary_exp_by_level(level)
    end
  end

  def max_exp
    calculate_total_necessary_exp(@min_level, max_level)
  end

  def level_status
    @cached_current_level_status = generate_status_of_current_level() unless @cached_current_level_status
    @cached_current_level_status.dup
  end

  def level
    level_status[:level]
  end

  def is_reached_max_level?
    level == max_level
  end

  def alter_exp(exp_delta)
    raise ArgumentError.new('exp_delta is not a integer') unless exp_delta.is_a?(Integer)
    before_exp = @exp
    change_exp_result = change_exp(@exp + exp_delta)
    self.class.generate_exp_change_result(
      before_exp, @exp, change_exp_result[:before_level], change_exp_result[:after_level])
  end

  def obtain_exp(increase_of_exp)
    raise ArgumentError.new('increase_of_exp is less than 0') if increase_of_exp < 0
    alter_exp(increase_of_exp)
  end

  def drain_exp(decrease_of_exp)
    raise ArgumentError.new('decrease_of_exp is less than 0') if decrease_of_exp < 0
    alter_exp(-decrease_of_exp)
  end

  def clear_exp
    change_exp(0)
    nil
  end

  private

  def self.generate_exp_change_result(before_exp, after_exp, before_level, after_level)
    {
      before_exp: before_exp,
      after_exp: after_exp,
      exp_delta: after_exp - before_exp,
      before_level: before_level,
      after_level: after_level,
      level_delta: after_level - before_level,
      is_leveling_up: after_level > before_level,
      is_leveling_down: after_level < before_level
    }
  end

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

  def guess_level_from_necessary_exps_index(index)
    @min_level + index + 1
  end

  def generate_status_of_current_level
    current_level = @min_level
    next_necessary_exp = nil
    total_necessary_exp = 0
    obtained_exp_for_next = nil
    lacking_exp_for_next = nil

    @necessary_exps.each_with_index do |necessary_exp, index|
      total_necessary_exp += necessary_exp

      if @exp < total_necessary_exp
        next_necessary_exp = necessary_exp
        lacking_exp_for_next = total_necessary_exp - @exp
        obtained_exp_for_next = next_necessary_exp - lacking_exp_for_next
        break
      end

      current_level = guess_level_from_necessary_exps_index(index)
    end

    {
      level: current_level,
      next_necessary_exp: next_necessary_exp,
      lacking_exp_for_next: lacking_exp_for_next,
      obtained_exp_for_next: obtained_exp_for_next
    }
  end

  def clear_cached_current_level_status
    @cached_current_level_status = CLEARED_CACHED_CURRENT_LEVEL_STATUS
  end

  def cut_exp_into_valid_range(exp)
    [[exp, max_exp].min, 0].max
  end

  def change_exp(exp)
    before_level = level
    @exp = cut_exp_into_valid_range(exp)
    clear_cached_current_level_status
    {
      before_level: before_level,
      after_level: level
    }
  end
end
