import std/[strutils, math]

const TargetFile = "day2/test.txt"

let input = readFile(TargetFile).strip()
var total = 0

for ranges in input.split(","):
    let parts = ranges.split("-")
    let s = parseInt(parts[0].strip())
    let e = parseInt(parts[1].strip())

    let sStr = $s
    var current: int
    
    if sStr.len mod 2 != 0:
        # Case 1: Odd length (e.g., 998). 
        current = 10 ^ (sStr.len div 2)
    else:
        # Case 2: Even length. Take actual first half.
        let halfLen = sStr.len div 2
        let prefixStr = sStr[0 ..< halfLen]
        current = parseInt(prefixStr)
        
        let candidate = parseInt($current & $current)
        if candidate < s:
            inc current

    while true:
        let num_str = $current
        let min_num_str = num_str & num_str
        
        # Check if the number has grown too long (length check)
        # OR if the value exceeds end 'e' (value check)
        if min_num_str.len > ($e).len:
            break
            
        let min_num_val = parseInt(min_num_str)

        if min_num_val > e:
            break

        if min_num_val >= s:
            total += min_num_val
            
        inc current

echo total