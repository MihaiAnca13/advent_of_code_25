import std/[strutils, math, sequtils, algorithm, tables, strscans]

const TargetFile = "day8/input.txt"

type Point = array[3, int]
type Edge = tuple[dist: int, u, v: int]

# --- 1. DSU Helper Functions ---
# parent[i] stores the parent of node i.
var parent = initTable[int, int]()

# Recursive function to find the "root" representative of a group
proc find(i: int): int =
  if not parent.hasKey(i): parent[i] = i
  if parent[i] != i:
    parent[i] = find(parent[i]) # Path compression (optimization)
  return parent[i]

# Merges two groups. Returns TRUE if they were separate (successful merge).
proc union(i, j: int): bool =
  let rootI = find(i)
  let rootJ = find(j)
  if rootI != rootJ:
    parent[rootI] = rootJ
    return true # They were merged
  return false # They were already in the same group

# --- 2. Main Logic ---

var points: seq[Point]
var x, y, z: int

# Read Points
for line in lines(TargetFile):
  if scanf(line, "$i,$i,$i", x, y, z):
    points.add([x, y, z])

# Calculate ALL edges
var edges: seq[Edge]
for i in 0 ..< points.len:
  for j in i + 1 ..< points.len:
    let dx = points[i][0] - points[j][0]
    let dy = points[i][1] - points[j][1]
    let dz = points[i][2] - points[j][2]
    edges.add((dx*dx + dy*dy + dz*dz, i, j))

# Sort edges by distance (Smallest -> Largest)
edges.sort(proc (a, b: Edge): int = cmp(a.dist, b.dist))

# Iterate and Connect
var groupsCount = points.len # We start with N isolated points
echo "Starting with ", groupsCount, " separate groups."

for e in edges:
  if union(e.u, e.v):
    groupsCount -= 1
    
    # If we are down to 1 group, this edge is the one that connected everything!
    if groupsCount == 1:
      echo "------------------------------------------------"
      echo "ALL MERGED!"
      echo "Between points: ", points[e.u], " and ", points[e.v]
      echo "Answer: ", points[e.u][0] * points[e.v][0]
      echo "------------------------------------------------"
      break