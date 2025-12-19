import std/[strutils, math, sequtils, algorithm, tables, strscans, sets, deques]
import ../utils/utils

const TargetFile = "day11/input.txt"

var data = initTable[string, seq[string]]()

for line in lines(TargetFile):
    let first = line.split(": ")
    let vals = first[1].split(" ")
    data[first[0]] = vals

var memo = initTable[string, int]()

proc compute_paths(current: string): int =
    if memo.hasKey(current):
        return memo[current]

    if current == "out":
        return 1

    let nexts = data[current]
    var total = 0
    for n in nexts:
        total += compute_paths(n)
    result = total

    memo[current] = result

echo compute_paths("you")