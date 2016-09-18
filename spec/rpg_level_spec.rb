require 'spec_helper'
require 'pry'

describe RpgLevel do
  it 'has a version number' do
    expect(RpgLevel::VERSION).not_to be nil
  end

  describe '#initialize' do
    it 'should be initialized' do
      RpgLevel.new
    end
  end

  describe '#generate_necessary_exps' do
    let (:rpg_level) {
      RpgLevel.new
    }

    it 'can specify the max_level' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 3) {|level:, **rest| level}
      expect(necessary_exps.length).to be 2
      expect(necessary_exps.inject(:+)).to eq(2 + 3)
    end

    it 'can refer :min_level and :max_level in the block' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 3) do |data|
        data[:min_level] + data[:max_level] * 2
      end
      expect(necessary_exps.last).to eq(1 + 3 * 2)
    end

    it 'can use the :exps in the block' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 5) do |level:, generated_exps:, **rest|
        level - 1 + generated_exps.inject(0, :+)
      end
      expect(necessary_exps[0]).to eq(1)
      expect(necessary_exps[1]).to eq(2 + 1)
      expect(necessary_exps[2]).to eq(3 + (2 + 1) + 1)
      expect(necessary_exps[3]).to eq(4 + (3 + (2 + 1) + 1) + (2 + 1) + 1)
    end

    it 'can use :memo in the block' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 3) do |level:, memo:, **rest|
        if level == 2 then
          memo[:tmp] = 5
        elsif level == 3 then
          memo[:tmp] * 2
        end
      end
      expect(necessary_exps[0]).to be(5)
      expect(necessary_exps[1]).to be(5 * 2)
    end
  end

  describe '#define_exp_table_from_array' do
    it 'should be' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1, 2, 3])
      expect(rpg_level.necessary_exps.length).to eq 3
      expect(rpg_level.necessary_exps.frozen?).to eq true
      expect {rpg_level.define_exp_table_from_array([1.0])}.to raise_error ArgumentError
      expect {rpg_level.define_exp_table_from_array([-1])}.to raise_error ArgumentError
      expect {rpg_level.define_exp_table_from_array([1, 1.0])}.to raise_error ArgumentError
    end
  end

  describe '#define_exp_table' do
    let (:rpg_level) {
      RpgLevel.new
    }

    it 'should raise a ArgumentError if the max_level is less than the min_level' do
      expect {rpg_level.define_exp_table(0)}.to raise_error ArgumentError
    end

    it 'should raise a ArgumentError if block is not given' do
      expect {rpg_level.define_exp_table(1)}.to raise_error ArgumentError
    end

    it 'should be' do
      rpg_level.define_exp_table(3) {|level:, **rest| level}
      expect(rpg_level.necessary_exps.size).to be 2
      expect(rpg_level.necessary_exps[0]).to be 2
      expect(rpg_level.necessary_exps[1]).to be 3
    end
  end

  describe '#min_level' do
    it 'should be' do
      rpg_level = RpgLevel.new(min_level: 2)
      expect(rpg_level.min_level).to eq 2
    end
  end

  describe '#exp' do
    it 'should be' do
      rpg_level = RpgLevel.new
      expect(rpg_level.exp).to eq 0
      rpg_level.instance_variable_set(:@exp, 1)
      expect(rpg_level.exp).to eq 1
    end
  end

  describe '#max_level' do
    it 'should be' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table(5) {|level:, **rest| level}
      expect(rpg_level.max_level).to eq 5
    end

    it 'should be effected of the min_level' do
      rpg_level = RpgLevel.new(min_level: 2)
      rpg_level.define_exp_table_from_array([1, 1, 1])
      expect(rpg_level.max_level).to eq 5
    end
  end

  describe '#find_necessary_exp_by_level' do
    it 'should be' do
      rpg_level = RpgLevel.new(min_level: 5)
      rpg_level.define_exp_table_from_array([1, 2])
      expect(rpg_level.find_necessary_exp_by_level(4)).to eq nil
      expect(rpg_level.find_necessary_exp_by_level(5)).to eq 0
      expect(rpg_level.find_necessary_exp_by_level(6)).to eq 1
      expect(rpg_level.find_necessary_exp_by_level(7)).to eq 2
      expect(rpg_level.find_necessary_exp_by_level(8)).to eq nil
    end
  end

  describe '#calculate_total_necessary_exp' do
    it 'should be' do
      rpg_level = RpgLevel.new(min_level: 2)
      rpg_level.define_exp_table_from_array([1, 1, 1])
      expect(rpg_level.calculate_total_necessary_exp(2, 5)).to eq 3
      expect(rpg_level.calculate_total_necessary_exp(3, 5)).to eq 3
      expect(rpg_level.calculate_total_necessary_exp(2, 4)).to eq 2
      expect(rpg_level.calculate_total_necessary_exp(3, 3)).to eq 1
      expect(rpg_level.calculate_total_necessary_exp(2, 2)).to eq 0
      expect {rpg_level.calculate_total_necessary_exp(3, 2)}.to raise_error ArgumentError
      expect {rpg_level.calculate_total_necessary_exp(0, 5)}.to raise_error ArgumentError
      expect {rpg_level.calculate_total_necessary_exp(2, 6)}.to raise_error ArgumentError
    end
  end

  describe '#max_exp' do
    it 'should be' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1, 1])
      expect(rpg_level.max_exp).to eq 2
    end
  end

  describe '#generate_status_of_current_level' do
    it 'should be' do
      rpg_level = RpgLevel.new(min_level: 2)
      rpg_level.define_exp_table_from_array([1, 2])

      expect(rpg_level.send(:generate_status_of_current_level)).to eq({
        level: 2,
        next_necessary_exp: 1,
        lacking_exp_for_next: 1,
        obtained_exp_for_next: 0
      })

      rpg_level.instance_variable_set(:@exp, 1)
      expect(rpg_level.send(:generate_status_of_current_level)).to eq({
        level: 3,
        next_necessary_exp: 2,
        lacking_exp_for_next: 2,
        obtained_exp_for_next: 0
      })

      rpg_level.instance_variable_set(:@exp, 2)
      expect(rpg_level.send(:generate_status_of_current_level)).to eq({
        level: 3,
        next_necessary_exp: 2,
        lacking_exp_for_next: 1,
        obtained_exp_for_next: 1
      })

      rpg_level.instance_variable_set(:@exp, 3)
      expect(rpg_level.send(:generate_status_of_current_level)).to eq({
        level: 4,
        next_necessary_exp: nil,
        lacking_exp_for_next: nil,
        obtained_exp_for_next: nil
      })
    end
  end
end
