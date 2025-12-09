import std/[strutils, math, sequtils, algorithm]
import ../utils/utils

const TargetFile = "day5/input.txt"

var ranges: Pairs
var numbers: seq[int]

var mode = 0
for line in lines(TargetFile):
    case mode:
        of 0:  # reading ranges
            if line == "":
                mode = 1
                continue
            let numbers = line.split("-")
            ranges.add([parseInt(numbers[0]), parseInt(numbers[1])])
        of 1:  # reading numbers
            numbers.add(parseInt(line))
        else:
            echo "???"

var total = 0
for n in numbers:
    var fresh = false
    for r in ranges:
        if n >= r[0] and n <= r[1]:
            fresh = true
            break
    if fresh:
        inc total

echo total

# sort the ranges by first index
ranges.sort(proc(a, b: Pair): int {.closure.} =
    cmp(a[0], b[0])
)

var i = 0
while i + 1 < ranges.len:
    # 2 cases: first index is identical, in which case you take the biggest of the second index
    # and second indices cross, in which case you take the first index to max between second indices
    if ranges[i][0] == ranges[i+1][0] or ranges[i][1] >= ranges[i+1][0]:
        ranges[i][1] = max(ranges[i][1], ranges[i+1][1])
        ranges.delete(i+1)
    else:
        inc i

total = 0
for r in ranges:
    total += r[1] - r[0] + 1

echo total