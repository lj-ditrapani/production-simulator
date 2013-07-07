# Author:  Lyall Jonathan Di Trapani ===================================
# Code for work station objects
# Utilization active_count / num_steps


class sim.Dice
    # A set of dice
    constructor: (@dice_count, @min, random) ->
        @range = 6 - min + 1
        @random = if typeof random == 'undefined'
            Math.random
        else
            random

    roll_die: () ->
        # Roll a single die according to range and min
        Math.floor(@random() * @range) + @min

    roll_dice: () ->
        # Roll all dice
        val = 0
        for i in [0...@dice_count]
            val += @roll_die()
        val


class TDTags
    constructor: (
        @capacity, @wip, @produced, @total_capacity, 
        @total_produced, @utilization) ->

    get: (name) ->
        this[name]

    display: (values) ->
        # Display values of current state
        names = ['capacity', 'wip', 'produced', 'total_capacity', 
                 'total_produced', 'utilization']
        for i in [0...names.length]
            dom.set_text this[names[i]], values[i]


class sim.Station
    # Represents a single work station on a single team
    # Everything covered except:  display functions (dom)
    constructor: (@num, dice_count, min, @wip, random) ->
        @dice = new sim.Dice dice_count, min, random
        @capacity = 0
        @produced = 0
        @total_capacity = 0
        @total_produced = 0
        @active_count = 0

    toString: () ->
        "S#{@num} dice #{@dice} wip #{@wip} produced #{@produced} " + 
        "capacity #{@capacity} tp #{@total_produced} " + 
        "tc #{@total_capacity} ac #{@active_count}"

    set_dice_count: (dice_count) ->
        @dice.dice_count = dice_count

    roll_dice: () ->
        @capacity = @dice.roll_dice()

    is_active: (round_num) ->
        if @wip > 0
            true                # Must produce in WIP available
        else if @num == 1 and round_num < 5
            true                # Continue to induct WIP
        else
            false

    compute_additonal_wip: () ->
        if @num == 1
            0
        else
            @prev.produced

    compute_produced_and_wip: (round_num) ->
        if @num == 1 and round_num < 5
            [@capacity, 0]
        else if @capacity > @wip
            [@wip, 0]
        else 
            [@capacity, @wip - @capacity]

    update: (round_num) ->
        if not @is_active(round_num)
            @capacity = 0
            @produced = 0
            return
        @active_count += 1
        additional_wip = @compute_additonal_wip()
        # Update state according to new capacity value
        # Station 1 produces its capacity if round 1-4
        [@produced, @wip] = @compute_produced_and_wip(round_num)
        @wip += additional_wip
        @total_capacity += @capacity
        @total_produced += @produced

    get_utilization: (step_num) ->
        if step_num == 0
            0
        else
            Math.round(@active_count * 1.0 / step_num * 100)

    add_tds: (capacity, wip, produced, total_capacity, 
              total_produced, utilization) ->
        @tds = new TDTags capacity, wip, produced, total_capacity,
                                  total_produced, utilization

    get_td: (name) ->
        @tds.get name

    display: (step_num, round_num) ->
        # Display values of current state
        new_wip = if  @num == 1 and round_num < 5
            'N/A'
        else
            @wip;
        @tds.display [@capacity,
                      new_wip,
                      @produced,
                      @total_capacity,
                      @total_produced,
                      @get_utilization(step_num)]
