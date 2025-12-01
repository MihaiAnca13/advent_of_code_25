import std/[strutils, math]

const TargetFile = "day1/input.txt"

var
  c = 50
  total = 0
  crossings = 0
  target = 0
  p1_total = 0

for line in lines(TargetFile):
  if line.len == 0: continue

  let value = line[1 .. ^1].parseInt

  if line[0] == 'R':
    target = c + value
    crossings = int((target / 100).floor - (c / 100).floor)

  elif line[0] == 'L':
    target = c - value
    crossings = int(((c - 1) / 100).floor - ((target - 1) / 100).floor)

  total += crossings
  c = target.floorMod(100)

  if c == 0:
    inc p1_total

echo p1_total
echo total
