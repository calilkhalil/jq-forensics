# Convert timestamp to human-readable format
# Input: ISO 8601 string or Unix timestamp (seconds/milliseconds)
# Output: string "YYYY-MM-DD HH:MM:SS" or null
def toreadable:
  if type == "string" then
    if test("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}") then
      split("T") as $parts |
      if ($parts | length) == 2 then
        $parts[0] + " " + (
          $parts[1] 
          | split(".")[0]
          | split("Z")[0]
          | split("+")[0]
          | split("-")[0]
          | if test("^\\d{2}:\\d{2}:\\d{2}$") then . else split("-")[0] end
        )
      else
        error("toreadable: malformed ISO 8601 timestamp")
      end
    else
      error("toreadable: input string must be valid ISO 8601 format")
    end
  elif type == "number" then
    if . < 0 then
      error("toreadable: timestamp cannot be negative")
    elif . == 0 then
      null
    elif . > 253402300799000 then
      error("toreadable: timestamp out of valid range")
    else
      if . > 9999999999 then
        (. / 1000 | todateiso8601 | toreadable)
      else
        (todateiso8601 | toreadable)
      end
    end
  elif . == null then
    null
  else
    error("toreadable: input must be string, number, or null")
  end;
