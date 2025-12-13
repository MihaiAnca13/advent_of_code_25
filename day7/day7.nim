import std/[strutils, math, sequtils, algorithm, tables]
import ../utils/utils

const TargetFile = "day7/input.txt"


proc get_next(diagram: seq[string], current: tuple[i, j: int]): seq[tuple[i, j: int]] =
    if current.i == diagram.len - 1:
        return @[]

    if diagram[current.i + 1][current.j] == '|':
        result.add((current.i + 1, current.j))
        return result
    elif diagram[current.i + 1][current.j] == '^':
        if current.j > 0:
            result.add((current.i + 1, current.j - 1))
        if current.j < diagram[current.i].len - 1:
            result.add((current.i + 1, current.j + 1))
        return result


var diagram = readFile(TargetFile).splitLines
var total = 0  

var start_j: int

for i, line in diagram:
    for j, c in line:
        if c == 'S':
            start_j = j
        if c == 'S' and diagram[i + 1][j] == '.':
            diagram[i][j] = '|'
        elif c == '.' and i > 0 and diagram[i - 1][j] == '|':
            diagram[i][j] = '|'
        elif c == '^' and diagram[i - 1][j] == '|':
            inc total
            if j > 0 and diagram[i][j - 1] == '.':
                diagram[i][j - 1] = '|'
            if j < diagram[i].len - 1 and diagram[i][j + 1] == '.':
                diagram[i][j + 1] = '|'

echo total

var memo = initTable[tuple[i, j: int], int]()

proc compute_timelines(current: tuple[i, j: int]): int =
    if memo.hasKey(current):
        return memo[current]

    let nexts = get_next(diagram, current)
    if nexts.len == 0:
        result = 1
    else:
        var total = 0
        for n in nexts:
            total += compute_timelines(n)
        result = total

    memo[current] = result

echo compute_timelines((0, start_j))


# var timeline_nr = 0
# var current: tuple[i, j: int] = (0, start_j) 
# var stack: seq[tuple[i, j: int]] 
# stack.add(current) 
# while true: 
#     current = stack[^1]
#     stack.delete(stack.high) 
#     let nexts = get_next(diagram, current)
#     if nexts.len == 0:
#         inc timeline_nr
#     for r in nexts: 
#         stack.add(r) 
#     if stack.len == 0: 
#         break

# echo timeline_nr