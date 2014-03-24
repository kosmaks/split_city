crossComparator = (origin) -> (x, y) ->
  x = [x[0] - origin[0], x[1] - origin[1], 0]
  y = [y[0] - origin[0], y[1] - origin[1], 0]
  cross = [
      x[1] * y[2] - x[2] * y[1],
      x[2] * y[0] - x[0] * y[2],
      x[0] * y[1] - x[1] * y[0]
  ]
  if cross[2] == 0 then 0 else
    if cross[2] > 0 then 1 else -1

grahamScan = (src) ->
  # Step 1
  data     = src.splice 0
  min      = data[0][0]
  minIndex = 0
  for index, vec of data
    if vec[0] < min
      min = vec[0]
      minIndex = Number index

  # Step 2
  edge = data[minIndex]
  data.splice minIndex, 1
  data.sort crossComparator(edge)

  # Step 3
  res = [edge, data[0]]
  for i in [1...data.length]
    point = data[i]
    while res.length > 2 and
        crossComparator(res[res.length - 1])(res[res.length - 2], point) <= 0
      res.pop()
    res.push point
  res

findPolygons = (clusters) ->
  for k, info of clusters
    info.polygon = grahamScan info.data

findMaxCategory = (clusters) ->
  for k, info of clusters
    for _, cat of info.categories
      if !info.category? or cat.count > info.category.count
        info.category = cat

splitClusters = (venues, weights) ->
  clusters = {}
  for i, venue of venues
    cluster = 0
    maxVal = 0
    for j, weight of weights[i]
      if weight > maxVal
        maxVal = weight
        cluster = j

    clusters[cluster] ?= {
      data: [],
      venues: [],
      size: 0,
      minWeight: null,
      maxWeight: null,
      categories: {}
      categoriesCount: 0
    }

    venue.weights = weights[i]

    info = clusters[cluster]
    info.data.push [venue.lat, venue.lng]
    info.venues.push venue
    info.size += 1

    if info.minWeight == null or info.minWeight > maxVal
      info.minWeight = maxVal
    if info.maxWeight == null or info.maxWeight < maxVal
      info.maxWeight = maxVal

    for cat in venue.categories
      info.categories[cat.id] ?= {
        count: 0
        name: cat.name
      }
      info.categoriesCount += 1
      info.categories[cat.id].count += 1
  clusters

main = ->
  weights       = @opts.weights
  venues        = @opts.venues
  clusters      = { }

  clusters = splitClusters venues, weights
  findMaxCategory clusters
  findPolygons clusters

  { clusters: clusters }

@onmessage = (input) ->
  @opts  = input.data
  @debug = -> console.log.apply console, arguments if opts.debug
  postMessage main()
