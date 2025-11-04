# Convert WebKit/Chrome timestamp to ISO 8601
# Input: number (microseconds since 1601-01-01 UTC)
# Output: string (ISO 8601 format) or null
def fromwebkit:
  if type == "number" then
    if . < 0 then
      error("fromwebkit: timestamp cannot be negative")
    elif . == 0 then
      null
    elif . > 265000000000000000 then
      error("fromwebkit: timestamp out of valid range")
    else
      ((. / 1000000) - 11644473600) | todateiso8601
    end
  elif . == null then
    null
  else
    error("fromwebkit: input must be number or null")
  end;
