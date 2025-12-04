import std/[strutils, math, sets, sequtils]

const TargetFile = "day2/input.txt"

proc get_multiplier(chunk_len, repeats: int): int =
  var m_str = ""
  # The pattern is '1' followed by (chunk_len-1) '0's
  let part = "1" & repeat("0", chunk_len - 1) 
  result = 0
  for i in 0 ..< repeats:
    result += 10 ^ (i * chunk_len)

let input = readFile(TargetFile).strip()
var found_ids = initHashSet[int]()
var total = 0

for ranges in input.split(","):
  let parts = ranges.split("-")
  let s = parseInt(parts[0].strip())
  let e = parseInt(parts[1].strip())

  let start_len = ($s).len
  let end_len = ($e).len

  for total_len in start_len .. end_len:
    
    # The chunk size must be at least 1, and at most half the total length 
    # (because it must repeat at least twice)
    for chunk_len in 1 .. (total_len div 2):
      
      # We only care if the chunk fits perfectly into the total length
      if total_len mod chunk_len == 0:
        let repeats = total_len div chunk_len
        let multiplier = get_multiplier(chunk_len, repeats)

        # Calculate smallest valid base number for this chunk size
        # It must be at least 10^(chunk_len-1) (e.g., if chunk is 2, min is 10)
        let min_base_magnitude = 10 ^ (chunk_len - 1)
        let max_base_magnitude = (10 ^ chunk_len) - 1

        # Determine math bounds based on S and E
        # ceil(s / multiplier)
        var start_base = (s + multiplier - 1) div multiplier 
        # floor(e / multiplier)
        var end_base = e div multiplier

        # Clamp bounds to ensure the base actually has 'chunk_len' digits
        start_base = max(start_base, min_base_magnitude)
        end_base = min(end_base, max_base_magnitude)

        if start_base > end_base:
          continue

        for base_num in start_base .. end_base:
          let final_id = base_num * multiplier
          
          if final_id >= s and final_id <= e:
            if final_id notin found_ids:
              found_ids.incl(final_id)
              total += final_id
            #   echo "Found invalid ID: ", final_id, " (base: ", base_num, ", x", repeats, ")"

echo "---"
echo "Total Sum: ", total