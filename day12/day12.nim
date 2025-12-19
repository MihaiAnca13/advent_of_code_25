import std/[strutils, math, sequtils, algorithm, tables, strscans, sets, deques]
import ../utils/utils

const TargetFile = "day12/input.txt"


var
  shapeAreas = initTable[int, int]()
  currentShapeIdx = 0
  validRegions = 0

for line in lines(TargetFile):
  if line.strip().endsWith(":"):
    currentShapeIdx = parseInt(line.strip()[0 .. ^2])
    shapeAreas[currentShapeIdx] = 0

  elif '#' in line:
    shapeAreas[currentShapeIdx] += line.count('#')

  elif 'x' in line:
    let parts = line.split(':')
    let dims = parts[0].split('x')
    let width = dims[0].strip().parseInt()
    let height = dims[1].strip().parseInt()
    let counts = parts[1].splitWhitespace().map(parseInt)

    var presentsArea = 0
    for i, count in counts.pairs:
      presentsArea += count * shapeAreas[i]

    if presentsArea <= width * height:
      validRegions.inc

echo validRegions
