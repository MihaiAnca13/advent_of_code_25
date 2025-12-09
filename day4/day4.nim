import std/[strutils, math]
import ../utils/utils

const TargetFile = "day4/input.txt"


var
    m: Matrix

# construct matrix
for line in lines(TargetFile):
    var row: seq[int]
    for c in line:
        case c:
            of '@':
                row.add(1)
            of '.':
                row.add(0)
            else:
                echo "unrecognized"
    m.add(row)

var total = 0

while true:
    let result = shift_matrix(m, 1, 0) + shift_matrix(m, -1, 0) + shift_matrix(m, 1, 1) + shift_matrix(m, -1, -1) + shift_matrix(m, 0, 1) + shift_matrix(m, 0, -1) + shift_matrix(m, 1, -1) + shift_matrix(m, -1, 1) 

    var total_removable = 0
    for i in 0 ..< m.len:
        for j in 0 ..< m[0].len:
            if result[i][j] < 4 and m[i][j] == 1:
                inc total_removable
                m[i][j] = 0

    if total_removable == 0:
        break

    total += total_removable

echo total