import std/[strutils, math, sets, sequtils]

const TargetFile = "day2/test.txt"

# 1. Pure Math Helper
# Calculates the multiplier. 
# e.g., chunk_len 2, repeats 3 -> returns 10101
# marked as 'func' because it has no side effects
func patternMultiplier(chunkLen, repeats: int): int =
  result = 0
  for i in 0 ..< repeats:
    result += 10 ^ (i * chunkLen)

# 2. The Logic Iterator
# Yields every valid repeated pattern within a specific range.
# This abstracts away the complexity of lengths and bounds.
iterator findPatterns(minVal, maxVal: int): int =
  let 
    startLen = ($minVal).len
    endLen   = ($maxVal).len

  # Iterate through possible total lengths (e.g., 2 digits, 3 digits...)
  for totalLen in startLen .. endLen:
    # Iterate through possible chunk sizes (1 digit repeated, 2 digits repeated...)
    for chunkLen in 1 .. (totalLen div 2):
      
      # Strict requirement: Total length must be divisible by chunk length
      if totalLen mod chunkLen == 0:
        let repeats = totalLen div chunkLen
        let multiplier = patternMultiplier(chunkLen, repeats)
        
        # Determine strict bounds for the Base number
        let 
          # The smallest number with 'chunkLen' digits (e.g., 2 digits -> 10)
          minBaseMagnitude = 10 ^ (chunkLen - 1)
          # The largest number with 'chunkLen' digits (e.g., 2 digits -> 99)
          maxBaseMagnitude = (10 ^ chunkLen) - 1

          # Math Trick: (A + B - 1) / B is Integer Ceiling Division
          startBaseCalc = (minVal + multiplier - 1) div multiplier
          endBaseCalc   = maxVal div multiplier

          # Clamp the range to ensure we stay within the digit limits
          startBase = max(startBaseCalc, minBaseMagnitude)
          endBase   = min(endBaseCalc, maxBaseMagnitude)

        # Yield valid numbers
        if startBase <= endBase:
          for baseNum in startBase .. endBase:
            yield baseNum * multiplier

# --- Main Program ---

let input = readFile(TargetFile).strip()
var uniqueIds = initHashSet[int]()

for rangeStr in input.split(","):
  # Clean parsing
  let parts = rangeStr.split("-").mapIt(it.strip.parseInt)
  let (s, e) = (parts[0], parts[1])

  # The iterator makes this loop incredibly readable
  for id in findPatterns(s, e):
    uniqueIds.incl(id)

# Sum the unique set
var total = 0
for id in uniqueIds:
  total += id

echo "Total: ", total