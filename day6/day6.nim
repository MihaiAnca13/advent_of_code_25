import std/[strutils, math, sequtils, algorithm]
import ../utils/utils

const TargetFile = "day6/input.txt"

## THIS ONLY WORKS WITH STRIPPED INPUT FILES


var numbers: seq[seq[int]]
var symbols: seq[char]

for line in lines(TargetFile):
    var row: seq[int]
    for number in line.split(" "):
        if number != "*" and number != "+":
            row.add(parseInt(number))
        else:
            symbols.add(number)
    if row.len > 0:
        numbers.add(row)

var total: seq[int]

for i in 0 ..< symbols.len:
    case symbols[i]:
        of '*':
            total.add(1)
        of '+':
            total.add(0)
        else:
            echo "???"

for j in 0 ..< numbers[0].len:
    for i in 0 ..< numbers.len:
        case symbols[j]:
            of '*':
                total[j] *= numbers[i][j]
            of '+':
                total[j] += numbers[i][j]
            else:
                echo "??"
         
echo total.sum