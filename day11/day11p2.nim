import std/[strutils, math, sequtils, algorithm, tables, strscans, sets, deques]

const TargetFile = "day11/input.txt"

var data = initTable[string, seq[string]]()

for line in lines(TargetFile):
    let first = line.split(": ")
    let vals = first[1].split(" ")
    data[first[0]] = vals

# using NodeName, SawFFT, SawDAC
var memo = initTable[(string, bool, bool), int]()

proc compute_paths(current: string, saw_fft: bool, saw_dac: bool): int =
    let now_saw_fft = saw_fft or (current == "fft")
    let now_saw_dac = saw_dac or (current == "dac")

    if memo.hasKey((current, now_saw_fft, now_saw_dac)):
        return memo[(current, now_saw_fft, now_saw_dac)]

    if current == "out":
        # Only count this path if we have seen both nodes
        if now_saw_fft and now_saw_dac:
            return 1
        else:
            return 0

    if not data.hasKey(current):
        return 0

    let nexts = data[current]
    var total = 0
    for n in nexts:
        total += compute_paths(n, now_saw_fft, now_saw_dac)
    
    result = total

    memo[(current, now_saw_fft, now_saw_dac)] = result

echo compute_paths("svr", false, false)
