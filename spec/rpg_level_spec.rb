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

    it 'can refer the :max_level in the block' do
      necessary_exps = rpg_level.send(:generate_necessary_exps, 3) do |data|
        data[:max_level]
      end
      expect(necessary_exps.last).to eq 3
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

  #describe '#define_exp_table' do
  #  let (:rpg_level) {
  #    RpgLevel.new
  #  }

  #  it 'should raise a ArgumentError unless block is given' do
  #    expect {rpg_level.send(:generate_necessary_exps)}.to raise_error ArgumentError
  #  end

  #  it 'has default args' do
  #    rpg_level.define_exp_table {|level:, **rest| level}
  #    expect(rpg_level.necessary_exps.size).to be 99
  #    expect(rpg_level.necessary_exps[0]).to be 0
  #    expect(rpg_level.necessary_exps[1]).to be 2
  #    expect(rpg_level.necessary_exps[98]).to be 99
  #  end

  #  it 'can specify :start_level and :max_level' do
  #    rpg_level.define_exp_table(start_level: 2, max_level: 4) {|level:, **rest| level}
  #    expect(rpg_level.necessary_exps.size).to be 4
  #    expect(rpg_level.necessary_exps[1]).to be 0
  #    expect(rpg_level.necessary_exps[2]).to be 3
  #    expect(rpg_level.necessary_exps[3]).to be 4
  #  end
  #end

  #describe '#min_level' do
  #  let (:rpg_level) {
  #    RpgLevel.new
  #  }

  #  it 'should be' do
  #    rpg_level.define_exp_table {|level:, **rest| level}
  #    expect(rpg_level.min_level).to eq 1
  #  end
  #end

  #describe '#max_level' do
  #  let (:rpg_level) {
  #    RpgLevel.new
  #  }

  #  it 'should be' do
  #    rpg_level.define_exp_table(max_level: 5) {|level:, **rest| level}
  #    expect(rpg_level.max_level).to eq 5
  #  end
  #end
end
