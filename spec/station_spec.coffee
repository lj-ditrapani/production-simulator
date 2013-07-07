# Author:  Lyall Jonathan Di Trapani ===================================
random = () -> 0.9999   # mock random (not actually random)

module 'Dice',
    setup: ->
        @dice = new sim.Dice 2, 1, random


test 'roll_die', ->
    equal @dice.roll_die(), 6


test 'roll_dice', ->
    equal @dice.roll_dice(), 12

        
module 'Station',
    setup: ->
        #            Station num dice_count min wip random
        station = new sim.Station 2, 2, 1, 4, random
        station.prev = {produced: 3}
        station.total_capacity = 7
        station.total_produced = 5
        @station = station


test 'random dice', ->
    station = new sim.Station 2, 2, 1, 4
    station.roll_dice()
    ok station.capacity >= 1
    ok station.capacity <= 12


test 'roll_dice', ->
    @station.roll_dice()
    equal @station.capacity, 12


test 'When a station updates', ->
    station = @station
    station.roll_dice()
    station.update(1)
    equal station.total_produced, 5 + 4, ('The new total_produced =' +
        ' the previous total_produced + what it produced this step')
    equal station.total_capacity, 7 + 12, ('The new total_capacity =' +
        ' the previous total_capacity + its capacity this step')
    

test "During update, when a station's capacity is > its WIP", ->
    station = @station
    station.roll_dice()
    station.update(1)
    equal station.produced, 4, 'It produces its starting WIP'
    equal station.wip, 3, 'Its WIP goes to 0 + prev.produced'


test 'During update, when Station 1 is inactive', ->
    station = @station
    station.capacity = 5
    station.produced = 5
    deepEqual [station.capacity, station.produced], [5, 5], 'Init'
    station.wip = 0         # causes station 2 to be inactive
    station.roll_dice()
    station.update(1)
    equal station.wip, 0, 'WIP still 0'
    equal station.produced, 0, 'produced goes to 0'
    equal station.capacity, 0, 'capacity does not count, = 0'
    equal station.total_capacity, 7, 'total_capacity still 7'
    equal station.total_produced, 5, 'total_produced still 5'
    equal station.active_count, 0, 'active_count still 0'


test "When a station's capacity <= to its WIP and updates", ->
    station = @station
    station.wip = 20
    station.roll_dice()
    station.update(1)
    equal station.produced, 12, 'It produces == to its capacity'
    equal station.wip, 8 + 3, ('Its WIP goes to starting WIP -' +
        ' capacity + prev.produced')


test 'When Station 1 has 0 WIP on round 1 and it updates', ->
    station = @station
    station.num = 1             # station 1
    station.set_dice_count 1    # only one dice (will roll 6)
    station.wip = 0             # 0 WIP because it is station 1
    station.roll_dice()
    station.update(1)
    s = station
    deepEqual [s.wip, s.produced, s.total_produced, s.total_capacity], 
              [0, 6, 11, 13], 
              "After 1st step, WIP=#{s.wip} produced=#{s.produced} " +
              "tp=#{s.total_produced} tc=#{s.total_capacity}"
    station.roll_dice()
    station.update(1)
    deepEqual [s.wip, s.produced, s.total_produced, s.total_capacity], 
              [0, 6, 17, 19], 
              "After 2st step, WIP=#{s.wip} produced=#{s.produced} " +
              "tp=#{s.total_produced} tc=#{s.total_capacity}"


test 'During update, when Station 1 has 20 WIP on round 5 and its ' + 
     'capacity is less than its WIP', ->
    station = @station
    station.num = 1         # station 1
    station.wip = 20        # 20 WIP to start
    station.roll_dice()
    station.update(5)
    # new WIP = old WIP - capacity  (no additional WIP)
    equal station.wip, 20 - 12, 'WIP is starting WIP - capacity'
    equal station.produced, 12, 'it produces == to its capacity'


test 'During update, when Station 1 has 10 WIP on round 5 and its ' + 
     'capacity is more than its WIP', ->
    station = @station
    station.num = 1         # station 1
    station.wip = 10        # 20 WIP to start
    station.roll_dice()
    station.update(5)
    equal station.produced, 10, 'it produces all the available WIP (10)'
    equal station.wip, 0, "its WIP is exhausted; WIP = 0"


test 'is active when WIP > 0', ->
    ok @station.is_active(1), 'Station 2 with WIP = 4'
    @station.num = 1
    ok @station.is_active(1), 'Station 1 with WIP = 4'


test 'station 1 is active on round <= 4 when WIP = 0', ->
    @station.num = 1
    @station.wip = 0
    ok @station.is_active(4), 'Station 1, round 4, with WIP = 0'
    

test 'station 1 is NOT active on round >= 5 when WIP = 0', ->
    @station.num = 1
    @station.wip = 0
    ok not @station.is_active(5), 'Station 1, round 5, with WIP = 0'
    

test 'does not update if not active', ->
    station = @station
    station.wip = 0         # causes station 2 to be inactive
    station.roll_dice()
    station.update(1)
    equal station.wip, 0, 'WIP still 0'
    equal station.produced, 0, 'produced still 0'
    equal station.capacity, 0, 'capacity does not count, = 0'
    equal station.total_capacity, 7, 'total_capacity still 7'
    equal station.total_produced, 5, 'total_produced still 5'
    equal station.active_count, 0, 'active_count still 0'


test 'add_tds', ->
    s = @station
    s.add_tds 1, 2, 3, 4, 5, 6, 7
    names = ['wip', 'total_capacity', 'utilization', 'efficiency']
    results = (s.get_td name for name in names)
    deepEqual results, [2, 4, 6, 7]


test 'get_utilization', ->
    s = @station
    s.roll_dice()
    s.update(1)
    s.roll_dice()
    s.update(1)
    equal @station.get_utilization(2), 100
    s.wip = 0
    s.roll_dice()
    s.update(1)
    s.roll_dice()
    s.update(1)
    equal @station.get_utilization(4), 50


test 'get_efficiency', ->
    s = @station
    equal s.get_efficiency(), 71, '5 total_prod / 7 total_cap = 71%'
    s.roll_dice()       # adds 12 to total_cap -> 7 + 12 = 19
    s.update(1)         # adds 4 to total_prod -> 4 + 5 = 9
    equal s.get_efficiency(), 47, '9 total_prod / 19 total_cap = 47%'
    s.roll_dice()       # adds 12 to total_cap -> 12 + 19 = 31
    s.update(1)         # adds 3 to total_prod -> 3 + 9 = 12
    equal s.get_efficiency(), 39, '12 total_prod / 31 total_cap = 39%'
