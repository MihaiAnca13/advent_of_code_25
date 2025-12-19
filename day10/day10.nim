import std/[strutils, math, sequtils, algorithm, tables, strscans, sets, deques]
import ../utils/utils

const TargetFile = "day10/input.txt"

type Machine = object
    target_state: seq[int]
    buttons: seq[seq[int]]
    jolts: seq[int]

type QueueItem = object
    presses: int = 0
    state: seq[int]


# Helper to remove surrounding chars and split by comma
proc parseNumbers(input: string): seq[int] =
    let content = input[1 .. ^2]
    if content.len == 0: return @[]
    result = content.split(',').map(parseInt)


var machines: seq[Machine]


for line in lines(TargetFile):
    if line.len == 0: continue
    
    let parts = line.split(' ')
    
    let rawState = parts[0][1 .. ^2]
    let target_state = rawState.mapIt(if it == '#': 1 else: 0)

    var buttons: seq[seq[int]] = @[]
    for i in 1 ..< parts.high:
        buttons.add(parseNumbers(parts[i]))

    let jolts = parseNumbers(parts[parts.high])

    machines.add(Machine(
        # state: newSeq[int](target_state.len),
        target_state: target_state,
        buttons: buttons,
        jolts: jolts
    ))


proc stateKey(s: seq[int]): string =
  # simple key; good enough for ints
  result = s.join(",")

proc pushButton(button: seq[int], state: seq[int]): seq[int] =
    result = state
    for i in button:
        result[i] = (result[i] + 1) mod 2


proc solve_machine(machine: Machine): int =
    var q = initDeque[QueueItem]()
    var visited = initHashSet[string]()
    let start_state = newSeq[int](machine.target_state.len)
    q.addLast(QueueItem(presses: 0, state: start_state))
    visited.incl stateKey(startState)

    while q.len > 0:
        let current = q.popFirst()

        if current.state == machine.target_state:
            return current.presses

        for b in machine.buttons:
            let new_state = pushButton(b, current.state)
            let k = stateKey(newState)
            if k notin visited:
                visited.incl(k)
                q.addLast(QueueItem(presses: current.presses + 1, state: new_state))

    return -1

var total = 0
for m in machines:
    total += solve_machine(m)

echo total
