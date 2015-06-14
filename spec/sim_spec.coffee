module 'sim'


test 'map', ->
  square = (x) -> x * x
  result = sim.map square, [1,2,3,4,5]
  deepEqual result, [1, 4, 9, 16, 25]


test 'remove', ->
  name = 'run'
  names = ['config', 'run', 'results']
  names = sim.remove names, name
  deepEqual names, ['config', 'results']
