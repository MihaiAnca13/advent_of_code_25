import std/[strutils, math, sequtils, algorithm]
import ../utils/utils

const TargetFile = "day6/input.txt"

var numbers_str: seq[seq[string]]
var symbols: seq[char]
var symbol_idx: seq[int]

for line in lines(TargetFile):
    if line[0] != '*' and line[0] != '+':
        continue
    for i, c in line:
        if c == '*' or c == '+':
            symbol_idx.add(i)
            symbols.add(c)

for line in lines(TargetFile):
    if line[0] == '*' or line[0] == '+':
        continue
    var row: seq[string]
    for i in 0 ..< symbol_idx.len:
        let idx1 = symbol_idx[i]
        var idx2 = line.len
        if i < symbol_idx.len - 1:
            idx2 = symbol_idx[i + 1]
        row.add(line[idx1..idx2 - 1])
    numbers_str.add(row)

var total: seq[int]

for i in 0 ..< symbols.len:
    case symbols[i]:
        of '*':
            total.add(1)
        of '+':
            total.add(0)
        else:
            echo "???"

var numbers = newSeq[seq[int]](symbols.len)

for j in 0 ..< numbers_str[0].len:
    for k in countdown(numbers_str[0][j].len - 1, 0):
        var formatted = ""
        for i in 0 ..< numbers_str.len:
            formatted = formatted & numbers_str[i][j][k]
        formatted = formatted.strip
        if formatted != "":
            numbers[j].add(parseInt(formatted))

for i in 0 ..< symbols.len:
    case symbols[i]:
        of '*':
            for num in numbers[i]:
                total[i] *= num
        of '+':
            for num in numbers[i]:
                total[i] += num
        else:
            echo "??"

echo total.sum
