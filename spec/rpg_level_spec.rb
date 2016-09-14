require 'spec_helper'

describe RpgLevel do
  let (:rpg_level) {
    RpgLevel.new
  }

  it 'has a version number' do
    expect(RpgLevel::VERSION).not_to be nil
  end

  it '#initialize' do
    RpgLevel.new
  end

  describe '#generate_necessary_exps' do
    it 'default args' do
      necessary_exps = rpg_level.send(:generate_necessary_exps) {|level:, **kwargs| level}
      expect(necessary_exps.size).to be 99
      expect(necessary_exps.inject(:+)).to be((2..99).inject(:+))
    end
  end
end
