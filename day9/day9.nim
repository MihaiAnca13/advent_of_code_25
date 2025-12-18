import std/[strutils, math, sequtils, algorithm, tables, strscans, sets]
import ../utils/utils

const TargetFile = "day9/input.txt"

var points: seq[Pair]
var x, y: int


proc dist(a: Pair, b: Pair): int =
    (a[0] - b[0]).abs + (a[1] - b[1]).abs

proc area(a: Pair, b: Pair): int =
    ((a[0] - b[0]).abs + 1) * ((a[1] - b[1]).abs + 1)

# Read Points
var max_coord: int = 0
for line in lines(TargetFile):
  if scanf(line, "$i,$i", x, y):
    points.add([x, y])
    max_coord = max(max(x, y), max_coord)


proc compute_min_max_points(zero: Pair, far: Pair): tuple[minP: Pair, maxP: Pair] =
    var 
        min_dist = max_coord ^ 2
        min_point: Pair
        max_dist = max_coord ^ 2
        max_point: Pair


    for point in points:
        let zero_corner_dist = dist(zero, point)
        let far_corner_dist = dist(far, point)

        if zero_corner_dist < min_dist:
            min_dist = zero_corner_dist
            min_point = point
        if far_corner_dist < max_dist:
            max_dist = far_corner_dist
            max_point = point
    
    result.minP = min_point
    result.maxP = max_point

let res1 = compute_min_max_points([0, 0], [max_coord, max_coord])
let res2 = compute_min_max_points([0, max_coord], [max_coord, 0])

echo max(area(res1.minP, res1.maxP), area(res2.minP, res2.maxP))

