module 'summary'

s = sim.summary_mod

test 'make_zero_grid', ->
    grid = [[0, 0],
            [0, 0]]
    deepEqual s.make_zero_grid(2, 2), grid
    grid = [[0, 0, 0],
            [0, 0, 0]]
    deepEqual s.make_zero_grid(2, 3), grid
