# Author:  Lyall Jonathan Di Trapani ===================================
# Code for work station objects
# Utilization active_count / num_steps


class sim.Dice
    # A set of dice
    constructor: (@dice_count, @min, max, random) ->
        @range = max - min + 1
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


class sim.HTMLTableDatas
    constructor: (@tds) ->

    display: (values) ->
        # Display values of current state
        for i in [0...@tds.length]
            dom.set_text @tds[i], values[i]


class sim.Station
    step_num = 0
    # Represents a single work station on a single team
    # Everything covered except:  display functions (dom)
    constructor: (@num, dice_count, min, max, @wip, random) ->
        @dice = new sim.Dice dice_count, min, max, random
        @capacity = 0
        @produced = 0
        @total_capacity = 0
        @total_produced = 0
        @active_count = 0

    toString: () ->
        "S#{@num} dice #{@dice} wip #{@wip} produced #{@produced} " + 
        "capacity #{@capacity} tp #{@total_produced} " + 
        "tc #{@total_capacity} ac #{@active_count} round #{@round_num}"

    set_dice_count: (dice_count) ->
        @dice.dice_count = dice_count

    roll_dice: () ->
        # Roll all dice
        @capacity = @dice.roll_dice()

    is_active: () ->
        if @wip > 0
            true                # Must produce in WIP available
        else if @num == 1 and @round_num < 5
            true                # Continue to induct WIP
        else
            false

    compute_additonal_wip: () ->
        if @num == 1
            0
        else
            @prev.produced

    compute_produced_and_wip: () ->
        if @num == 1 and @round_num < 5
            [@capacity, 0]
        else if @capacity > @wip
            [@wip, 0]
        else 
            [@capacity, @wip - @capacity]

    update: () ->
        if not @is_active()
            @capacity = 0
            @produced = 0
            return
        @active_count += 1
        additional_wip = @compute_additonal_wip()
        # Update state according to new capacity value
        # Station 1 produces its capacity if round 1-4
        [@produced, @wip] = @compute_produced_and_wip()
        @wip += additional_wip
        @total_capacity += @capacity
        @total_produced += @produced

    set_round_info: (@round_num, @num_steps) ->

    add_tds: (tds) ->
        @tds = new HTMLTableDatas tds

    display: () ->
        # Display values of current state
        new_wip = if  @num == 1 and @round_num < 5
            'N/A'
        else
            @wip;
        @tds.display [@capacity,
                      new_wip,
                      @total_capacity,
                      @total_produced,
                      @active_count * 1.0 / @step_num]
