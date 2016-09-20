require 'spec_helper'

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

  describe '#level_status and #level' do
    context '`min_level=2, necessary_exps=[1, 2]` definition' do
      let(:rpg_level) {
        rpg_level = RpgLevel.new(min_level: 2)
        rpg_level.define_exp_table_from_array([1, 2])
        rpg_level
      }

      it 'should generate status of 0 exp' do
        expect(rpg_level.level_status).to eq({
          level: 2,
          next_necessary_exp: 1,
          lacking_exp_for_next: 1,
          obtained_exp_for_next: 0
        })
      end

      it 'should generate status of 1 exp' do
        rpg_level.instance_variable_set(:@exp, 1)
        expect(rpg_level.level_status).to eq({
          level: 3,
          next_necessary_exp: 2,
          lacking_exp_for_next: 2,
          obtained_exp_for_next: 0
        })
      end

      it 'should generate status of 2 exp' do
        rpg_level.instance_variable_set(:@exp, 2)
        expect(rpg_level.level_status).to eq({
          level: 3,
          next_necessary_exp: 2,
          lacking_exp_for_next: 1,
          obtained_exp_for_next: 1
        })
      end

      it 'should generate status of 3 exp' do
        rpg_level.instance_variable_set(:@exp, 3)
        expect(rpg_level.level_status).to eq({
          level: 4,
          next_necessary_exp: nil,
          lacking_exp_for_next: nil,
          obtained_exp_for_next: nil
        })
      end
    end

    describe 'status cashing' do
      # TODO: How to rewrite this test like the following logic?:
      #       "#generate_status_of_current_level is called only once, even #level_status is called on many times"
      it 'should not generate status if its exp has no change' do
        rpg_level = RpgLevel.new(min_level: 2)
        rpg_level.define_exp_table_from_array([1, 2])
        expect(rpg_level.instance_variable_get(:@cached_current_level_status)).to eq nil

        rpg_level.level_status
        expect(rpg_level.instance_variable_get(:@cached_current_level_status)).not_to eq nil

        before_object_id = rpg_level.instance_variable_get(:@cached_current_level_status).object_id

        rpg_level.level_status
        expect(rpg_level.instance_variable_get(:@cached_current_level_status).object_id).to eq before_object_id
      end

      it 'returns duplicated hash always' do
        rpg_level = RpgLevel.new(min_level: 2)
        rpg_level.define_exp_table_from_array([1, 2])
        first_result = rpg_level.level_status
        second_result = rpg_level.level_status
        expect(first_result).not_to be second_result
      end
    end

    describe '#level' do
      it 'should be' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([1])
        expect(rpg_level.level).to eq 1

        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([1])
        rpg_level.instance_variable_set(:@exp, 1)
        expect(rpg_level.level).to eq 2
      end
    end
  end

  describe '#is_reached_max_level?' do
    it 'should be' do
      rpg_level = RpgLevel.new
      expect(rpg_level.is_reached_max_level?).to eq true

      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1])
      expect(rpg_level.is_reached_max_level?).to eq false
    end
  end

  describe '#change_exp' do
    it 'should regenerate the @cached_current_level_status' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1])
      rpg_level.level_status
      before_cache = rpg_level.instance_variable_get(:@cached_current_level_status)
      rpg_level.send(:change_exp, 0)
      after_cache = rpg_level.instance_variable_get(:@cached_current_level_status)
      expect(before_cache).not_to be after_cache
    end
  end

  describe '#alter_exp' do
    it 'can increase exp' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([2])

      altered = rpg_level.alter_exp(1)
      expect(altered).to eq({
        before_exp: 0,
        after_exp: 1,
        exp_delta: 1,
        before_level: 1,
        after_level: 1,
        level_delta: 0,
        is_leveling_up: false,
        is_leveling_down: false
      })
      expect(rpg_level.level_status).to eq({
        level: 1,
        next_necessary_exp: 2,
        lacking_exp_for_next: 1,
        obtained_exp_for_next: 1
      })

      altered = rpg_level.alter_exp(1)
      expect(altered).to eq({
        before_exp: 1,
        after_exp: 2,
        exp_delta: 1,
        before_level: 1,
        after_level: 2,
        level_delta: 1,
        is_leveling_up: true,
        is_leveling_down: false
      })
      expect(rpg_level.level_status).to eq({
        level: 2,
        next_necessary_exp: nil,
        lacking_exp_for_next: nil,
        obtained_exp_for_next: nil
      })
    end

    it 'can decrease exp' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([2])
      rpg_level.alter_exp(2)

      altered = rpg_level.alter_exp(-1)
      expect(altered).to eq({
        before_exp: 2,
        after_exp: 1,
        exp_delta: -1,
        before_level: 2,
        after_level: 1,
        level_delta: -1,
        is_leveling_up: false,
        is_leveling_down: true
      })
      expect(rpg_level.level_status).to eq({
        level: 1,
        next_necessary_exp: 2,
        lacking_exp_for_next: 1,
        obtained_exp_for_next: 1
      })

      altered = rpg_level.alter_exp(-1)
      expect(altered).to eq({
        before_exp: 1,
        after_exp: 0,
        exp_delta: -1,
        before_level: 1,
        after_level: 1,
        level_delta: 0,
        is_leveling_up: false,
        is_leveling_down: false
      })
      expect(rpg_level.level_status).to eq({
        level: 1,
        next_necessary_exp: 2,
        lacking_exp_for_next: 2,
        obtained_exp_for_next: 0
      })
    end

    it 'should obtain exp with multiple leveling up at a time' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1, 2, 4])
      obtained = rpg_level.alter_exp(6)
      expect(obtained).to eq({
        before_exp: 0,
        after_exp: 6,
        exp_delta: 6,
        before_level: 1,
        after_level: 3,
        level_delta: 2,
        is_leveling_up: true,
        is_leveling_down: false
      })
    end

    it 'should cut exp that exceeds the max exp' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1])
      rpg_level.alter_exp(1)
      expect(rpg_level.exp).to eq 1
      rpg_level.alter_exp(1)
      expect(rpg_level.exp).to eq 1
    end

    it 'should not update exp to less than 0' do
      rpg_level = RpgLevel.new
      expect(rpg_level.exp).to eq 0
      rpg_level.alter_exp(-1)
      expect(rpg_level.exp).to eq 0
    end

    it 'should raise a ArgumentError if exp_delta is not a Integer' do
      rpg_level = RpgLevel.new
      expect {rpg_level.alter_exp(1.0)}.to raise_error ArgumentError
    end
  end

  describe '#obtain_exp' do
    it 'should be' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1])
      expect(rpg_level.exp).to eq 0
      obtained = rpg_level.obtain_exp(1)
      expect(rpg_level.exp).to eq 1
      expect(obtained).to be_instance_of Hash
    end

    it 'should raise a ArgumentError if increase_of_exp is less than 0' do
      rpg_level = RpgLevel.new
      expect {rpg_level.obtain_exp(-1)}.to raise_error ArgumentError
    end
  end

  describe '#drain_exp' do
    it 'should be' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1])
      rpg_level.obtain_exp(1)
      expect(rpg_level.exp).to eq 1
      drained = rpg_level.drain_exp(1)
      expect(rpg_level.exp).to eq 0
      expect(drained).to be_instance_of Hash
    end

    it 'should raise a ArgumentError if decrease_of_exp is less than 0' do
      rpg_level = RpgLevel.new
      expect {rpg_level.drain_exp(-1)}.to raise_error ArgumentError
    end
  end

  describe '#clear_exp' do
    it 'should be' do
      rpg_level = RpgLevel.new
      rpg_level.define_exp_table_from_array([1])
      rpg_level.alter_exp(1)
      expect(rpg_level.exp).to eq 1
      rpg_level.clear_exp
      expect(rpg_level.exp).to eq 0
    end
  end

  describe '#obtain_exp_by_level' do
    it 'should raise ArgumentError' do
      rpg_level = RpgLevel.new
      expect {rpg_level.obtain_exp_by_level(1.0, :omitted)}.to raise_error ArgumentError
      expect {rpg_level.obtain_exp_by_level(-1, :omitted)}.to raise_error ArgumentError
      expect {rpg_level.obtain_exp_by_level(1, :invalid_mode)}.to raise_error ArgumentError
    end

    context 'fraction_mode = :omitted' do
      it 'should be' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([4, 8])
        rpg_level.obtain_exp(3)

        obtained = rpg_level.obtain_exp_by_level(1, :omitted)
        expect(obtained).to eq({
          before_exp: 3,
          after_exp: 4,
          exp_delta: 1,
          before_level: 1,
          after_level: 2,
          level_delta: 1,
          is_leveling_up: true,
          is_leveling_down: false
        })

        obtained = rpg_level.obtain_exp_by_level(1, :omitted)
        expect(obtained).to eq({
          before_exp: 4,
          after_exp: 12,
          exp_delta: 8,
          before_level: 2,
          after_level: 3,
          level_delta: 1,
          is_leveling_up: true,
          is_leveling_down: false
        })

        obtained = rpg_level.obtain_exp_by_level(1, :omitted)
        expect(obtained).to eq({
          before_exp: 12,
          after_exp: 12,
          exp_delta: 0,
          before_level: 3,
          after_level: 3,
          level_delta: 0,
          is_leveling_up: false,
          is_leveling_down: false
        })
      end

      it 'should omit exp fraction at multiple leveling up' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([3, 3, 3])
        rpg_level.obtain_exp(2)
        rpg_level.obtain_exp_by_level(2, :omitted)
        expect(rpg_level.exp).to eq 6
      end
    end

    context 'fraction_mode = :inherited' do
      it 'should be' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([4, 8])
        rpg_level.obtain_exp(3)

        obtained = rpg_level.obtain_exp_by_level(1, :inherited)
        expect(obtained).to eq({
          before_exp: 3,
          after_exp: 7,
          exp_delta: 4,
          before_level: 1,
          after_level: 2,
          level_delta: 1,
          is_leveling_up: true,
          is_leveling_down: false
        })

        obtained = rpg_level.obtain_exp_by_level(1, :inherited)
        expect(obtained).to eq({
          before_exp: 7,
          after_exp: 12,
          exp_delta: 5,
          before_level: 2,
          after_level: 3,
          level_delta: 1,
          is_leveling_up: true,
          is_leveling_down: false
        })

        obtained = rpg_level.obtain_exp_by_level(1, :inherited)
        expect(obtained).to eq({
          before_exp: 12,
          after_exp: 12,
          exp_delta: 0,
          before_level: 3,
          after_level: 3,
          level_delta: 0,
          is_leveling_up: false,
          is_leveling_down: false
        })
      end

      it 'should inherit exp fraction at multiple leveling up' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([3, 3, 3])
        rpg_level.obtain_exp(2)
        rpg_level.obtain_exp_by_level(2, :inherited)
        expect(rpg_level.exp).to eq 8
      end

      it 'should cut over inherited fraction exp' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([8, 8, 4])
        rpg_level.obtain_exp(7)
        rpg_level.obtain_exp_by_level(2, :inherited)
        expect(rpg_level.exp).to eq 19
      end
    end
  end

  describe '#drain_exp_by_level' do
    it 'should raise ArgumentError' do
      rpg_level = RpgLevel.new
      expect {rpg_level.drain_exp_by_level(1.0, :omitted)}.to raise_error ArgumentError
      expect {rpg_level.drain_exp_by_level(-1, :omitted)}.to raise_error ArgumentError
      expect {rpg_level.drain_exp_by_level(1, :invalid_mode)}.to raise_error ArgumentError
    end

    context 'fraction_mode = :omitted' do
      it 'should be' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([4, 8])
        rpg_level.obtain_exp(11)

        drained = rpg_level.drain_exp_by_level(1, :omitted)
        expect(rpg_level.exp).to eq 0
        expect(drained).to eq({
          before_exp: 11,
          after_exp: 0,
          exp_delta: -11,
          before_level: 2,
          after_level: 1,
          level_delta: -1,
          is_leveling_up: false,
          is_leveling_down: true
        })

        drained = rpg_level.drain_exp_by_level(1, :omitted)
        expect(rpg_level.exp).to eq 0
        expect(drained).to eq({
          before_exp: 0,
          after_exp: 0,
          exp_delta: 0,
          before_level: 1,
          after_level: 1,
          level_delta: 0,
          is_leveling_up: false,
          is_leveling_down: false
        })
      end

      it 'should omit exp fraction at multiple leveling down' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([3, 3, 3, 3])
        rpg_level.obtain_exp(11)
        rpg_level.drain_exp_by_level(2, :omitted)
        expect(rpg_level.exp).to eq 3
      end
    end

    context 'fraction_mode = :full' do
      it 'should be' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([4, 8])
        rpg_level.obtain_exp(5)

        drained = rpg_level.drain_exp_by_level(1, :full)
        expect(drained).to eq({
          before_exp: 5,
          after_exp: 3,
          exp_delta: -2,
          before_level: 2,
          after_level: 1,
          level_delta: -1,
          is_leveling_up: false,
          is_leveling_down: true
        })

        drained = rpg_level.drain_exp_by_level(1, :full)
        expect(drained).to eq({
          before_exp: 3,
          after_exp: 0,
          exp_delta: -3,
          before_level: 1,
          after_level: 1,
          level_delta: 0,
          is_leveling_up: false,
          is_leveling_down: false
        })

        drained = rpg_level.drain_exp_by_level(1, :full)
        expect(drained).to eq({
          before_exp: 0,
          after_exp: 0,
          exp_delta: 0,
          before_level: 1,
          after_level: 1,
          level_delta: 0,
          is_leveling_up: false,
          is_leveling_down: false
        })
      end

      it 'should keep exp fraction at multiple leveling down' do
        rpg_level = RpgLevel.new
        rpg_level.define_exp_table_from_array([3, 3, 3, 3])
        rpg_level.obtain_exp(10)
        rpg_level.drain_exp_by_level(2, :full)
        expect(rpg_level.exp).to eq 5
      end
    end
  end
end
