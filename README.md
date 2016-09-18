# RpgLevel

[![Build Status](https://travis-ci.org/kjirou/ruby-rpg_level.svg?branch=master)](https://travis-ci.org/kjirou/ruby-rpg_level)

Manage the [Level/EXP](http://gaming.wikia.com/wiki/Level_(RPG))
  that is known as the most commonly growth system of role-playing games.


## Feature

The feature of this module has been aggregated into the following formula:

```ruby
level = formula_of_exp_table(exp)
```

This design has been often used in the classic RPGs, such as "Wizardry", "D&D", "Rouge-like", ..etc.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rpg_level'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rpg_level


## Example

```ruby
require 'rpg_level'

rpg_level = RpgLevel.new

# Define EXP Table by formula
#
#   Lv1 = 0
#   Lv2 = 4
#   Lv3 = 6  (Total = 10)
#   Lv4 = 8  (Total = 18)
#   Lv5 = 10 (Total = 28)
#
rpg_level.define_exp_table(5) {|data| data[:level] * 2}

# Obtain 12 experience points
# It also means that leveling up at the same time
rpg_level.obtain_exp(12)

# Get current level
p(rpg_level.level)  # => 3

# Get more information
p(rpg_level.level_status)  # => {:level=>3, :next_necessary_exp=>8, :lacking_exp_for_next=>6, :obtained_exp_for_next=>2}
```
