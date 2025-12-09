import std/sequtils


type Matrix* = seq[seq[int]]


proc `+`*(a, b: Matrix): Matrix =
    ## Element-wise matrix addition.
    assert a.len == b.len
    assert a[0].len == b[0].len
    result = newSeq[seq[int]](a.len)
    for i in 0 ..< a.len:
        result[i] = newSeq[int](a[i].len)
        for j in 0 ..< a[i].len:
            result[i][j] = a[i][j] + b[i][j]


proc shift_matrix*(a: Matrix, dx: int, dy: int): Matrix =
    ## Shifts the matrix by (dx, dy).
    ## dx > 0 -> shift right, dx < 0 -> shift left
    ## dy > 0 -> shift down,  dy < 0 -> shift up
    let h = a.len
    let w = a[0].len
    result = newSeqWith(h, newSeq[int](w))
    for i in 0 ..< h:
        for j in 0 ..< w:
            let srcI = i - dy
            let srcJ = j - dx
            if srcI >= 0 and srcI < h and srcJ >= 0 and srcJ < w:
                result[i][j] = a[srcI][srcJ]
            else:
                result[i][j] = 0
