require 'spec_helper'

describe RpgLevel do
  it 'has a version number' do
    expect(RpgLevel::VERSION).not_to be nil
  end

  it '#initialize' do
    RpgLevel.new
  end

  describe '#generate_necessary_exps' do
    let (:rpg_level) {
      RpgLevel.new
    }

    it 'should raise a ArgumentError unless block is given' do
      expect {rpg_level.send(:generate_necessary_exps)}.to raise_error ArgumentError
    end

    it 'can specify start_level and max_level' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 2, 5) {|level:, **rest| level}
      expect(necessary_exps.size).to be 5
      expect(necessary_exps.inject(:+)).to be(3 + 4 + 5)
    end

    it 'can refer :min_level, :start_level and :max_level in the block' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 2, 3) do |data|
        data[:min_level] * data[:start_level] * data[:max_level]
      end
      expect(necessary_exps.last).to be(1 * 2 * 3)
    end

    it 'can use :exps in the block' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 1, 5) do |level:, exps:, **rest|
        level - 1 + exps.inject(:+)
      end
      expect(necessary_exps[1]).to be(1)
      expect(necessary_exps[2]).to be(2 + 1)
      expect(necessary_exps[3]).to be(3 + (2 + 1) + 1)
      expect(necessary_exps[4]).to be(4 + (3 + (2 + 1) + 1) + (2 + 1) + 1)
    end

    it 'can use :memo in the block' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 1, 3) do |level:, memo:, **rest|
        if level == 2 then
          memo[:tmp] = 5
        elsif level == 3 then
          memo[:tmp] * 2
        end
      end
      expect(necessary_exps[1]).to be(5)
      expect(necessary_exps[2]).to be(5 * 2)
    end
  end

  describe '#define_exp_table' do
    let (:rpg_level) {
      RpgLevel.new
    }

    it 'should raise a ArgumentError unless block is given' do
      expect {rpg_level.send(:generate_necessary_exps)}.to raise_error ArgumentError
    end

    it 'has default args' do
      rpg_level.define_exp_table {|level:, **rest| level}
      expect(rpg_level.necessary_exps.size).to be 99
      expect(rpg_level.necessary_exps[0]).to be 0
      expect(rpg_level.necessary_exps[1]).to be 2
      expect(rpg_level.necessary_exps[98]).to be 99
    end
  end
end
