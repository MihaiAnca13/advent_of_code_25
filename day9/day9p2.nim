import std/[strutils, math, sequtils, algorithm, tables, strscans, sets]

const TargetFile = "day9/input.txt"

type Pair = tuple[x, y: int]
type Edge = tuple[p1, p2: Pair; isVert: bool]

proc area(a, b: Pair): int =
  ((a.x - b.x).abs + 1) * ((a.y - b.y).abs + 1)

proc isInside(p: tuple[x, y: float], edges: seq[Edge]): bool =
  # Standard Ray Casting (Point in Polygon)
  # Cast a ray to the RIGHT from p. Count vertical walls we hit.
  var hits = 0
  for e in edges:
    if e.isVert:
      # Check if wall is to our right
      if float(e.p1.x) > p.x:
        # Check if wall spans our y-coordinate
        let minY = min(e.p1.y, e.p2.y).float
        let maxY = max(e.p1.y, e.p2.y).float
        if p.y > minY and p.y < maxY:
          hits.inc
  return (hits mod 2) != 0

proc hasIntrusion(r1, r2: Pair, edges: seq[Edge]): bool =
  # Checks if any polygon edge cuts strictly THROUGH the rectangle
  let minX = min(r1.x, r2.x)
  let maxX = max(r1.x, r2.x)
  let minY = min(r1.y, r2.y)
  let maxY = max(r1.y, r2.y)

  for e in edges:
    if e.isVert:
      # A vertical wall is an intrusion if it's strictly between x bounds
      # AND it overlaps the y bounds
      if e.p1.x > minX and e.p1.x < maxX:
        let wallMinY = min(e.p1.y, e.p2.y)
        let wallMaxY = max(e.p1.y, e.p2.y)
        # Check for segment overlap
        if wallMaxY > minY and wallMinY < maxY:
          return true
    else:
      # Horizontal wall intrusion
      if e.p1.y > minY and e.p1.y < maxY:
        let wallMinX = min(e.p1.x, e.p2.x)
        let wallMaxX = max(e.p1.x, e.p2.x)
        if wallMaxX > minX and wallMinX < maxX:
          return true
  return false

# --- Main ---

var points: seq[Pair]
var x, y: int

# 1. Parse (The list is already ordered!)
for line in lines(TargetFile):
  if scanf(line, "$i,$i", y, x): # Assuming y,x format based on puzzle text
    points.add((x: x, y: y))

# 2. Build Edge List
var edges: seq[Edge]
for i in 0 ..< points.len:
  let p1 = points[i]
  let p2 = points[(i + 1) mod points.len] # Wrap around
  edges.add((p1: p1, p2: p2, isVert: p1.x == p2.x))

# 3. Brute Force all Pairs
var maxArea = 0

for i in 0 ..< points.len:
  for j in (i + 1) ..< points.len:
    let p1 = points[i]
    let p2 = points[j]

    # Optimization: Skip if smaller than current max
    if area(p1, p2) <= maxArea: continue

    # Check 1: Is the precise center of this rectangle inside the polygon?
    # (Uses float to avoid hitting walls exactly)
    let midX = (p1.x + p2.x).float / 2.0
    let midY = (p1.y + p2.y).float / 2.0
    
    if not isInside((x: midX, y: midY), edges):
      continue

    # Check 2: Do any walls cut through the inside of this rectangle?
    if hasIntrusion(p1, p2, edges):
      continue

    # If we passed both, it's valid!
    let currentArea = area(p1, p2)
    if currentArea > maxArea:
      maxArea = currentArea

echo "Max Valid Area: ", maxArea