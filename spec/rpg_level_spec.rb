require 'spec_helper'
require 'pry'

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

    it 'can specify the max_level' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 3) {|level:, **rest| level}
      expect(necessary_exps.length).to be 2
      expect(necessary_exps.inject(:+)).to eq(2 + 3)
    end

    it 'should raise a ArgumentError if the max_level is less than the min_level' do
      expect {rpg_level.send(:generate_necessary_exps, 0)}.to raise_error ArgumentError
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
    end
  end

  describe '#define_exp_table' do
    let (:rpg_level) {
      RpgLevel.new
    }

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

  describe '#max_level' do
    it 'should be' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table(5) {|level:, **rest| level}
      expect(rpg_level.max_level).to eq 5
    end
  end

  #describe '#min_level' do
  #  let (:rpg_level) {
  #    RpgLevel.new
  #  }

  #  it 'should be' do
  #    rpg_level.define_exp_table {|level:, **rest| level}
  #    expect(rpg_level.min_level).to eq 1
  #  end
  #end
end
