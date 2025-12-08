import std/[strutils, math]

const TargetFile = "day3/input.txt"


proc reset(input: var array[12, char], idx: int) =
  for i in idx .. 11:
    input[i] = chr(ord('0') - 1)

var total = 0

for line in lines(TargetFile):
    var
        number: array[12, char]

    reset(number, 0)

    for i, c in line:
        for idx in 0 .. 11:
            if c > number[idx] and i < (line.len - 11 + idx):
                number[idx] = c
                reset(number, idx + 1)
                break
    total += parseInt(number.join)

echo total