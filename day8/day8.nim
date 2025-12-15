import std/[strutils, math, sequtils, algorithm, tables, strscans, sets]
import ../utils/utils

const TargetFile = "day8/input.txt"
const Operations = 1000

type 
    SmartPoint = object
        val: int
        idxs: tuple[i, j: int]

type Point = array[3, int]

proc reset(a: var array[Operations, SmartPoint], idx: int) =
    for i in idx ..< Operations:
        a[i].val = high(int)

proc euclidean(a, b: Point): int =
    let dx = (a[0] - b[0]).int
    let dy = (a[1] - b[1]).int
    let dz = (a[2] - b[2]).int
    result = dx*dx + dy*dy + dz*dz


var points: seq[Point]
var x, y, z: int
var maxes: array[Operations, SmartPoint]

reset(maxes, 0)

for line in lines(TargetFile):
    if scanf(line, "$i,$i,$i", x, y, z):
        points.add([x, y, z])

var cdist = newSeqWith(points.len, newSeq[int](points.len))
for i in 0 ..< points.len:
    for j in i + 1 ..< points.len:
        let new_val = euclidean(points[i], points[j])
        
        # update top Operations values and keep track of indices
        for idx in 0 ..< maxes.len:
            if new_val < maxes[idx].val:
                if idx < maxes.high:
                    for k in countdown(maxes.high, idx + 1):
                        maxes[k] = maxes[k-1]

                maxes[idx].val = new_val
                maxes[idx].idxs = (i, j)

                break

var groups: seq[HashSet[int]]
for sp in maxes:
    # 1. Start with the current pair as a "candidate group"
    var currentGroup = toHashSet([sp.idxs.i, sp.idxs.j])
    
    # 2. We will build a new list of groups that DO NOT overlap
    var nextGroups: seq[HashSet[int]]
    
    for g in groups:
        # Check intersection efficiently
        # If the existing group 'g' shares ANY node with our current cluster...
        if not disjoint(g, currentGroup):
            # ... merge 'g' into 'currentGroup'
            currentGroup.incl(g)
        else:
            # ... otherwise keep 'g' as is
            nextGroups.add(g)
    
    # 3. Add our (possibly grown) group to the list
    nextGroups.add(currentGroup)
    
    # 4. Update the main list
    groups = nextGroups


groups.sort(proc (a, b: HashSet[int]): int = cmp(b.len, a.len))
var total = 1
for g in groups[0 ..< 3]:
    total *= g.len

echo total