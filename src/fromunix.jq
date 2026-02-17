# Convert Unix timestamp to ISO 8601
# Input: number (seconds since 1970-01-01 00:00:00 UTC, or milliseconds if > 9999999999)
# Output: string (ISO 8601 format) or null
def fromunix:
  if type == "number" then
    if . < 0 then
      error("fromunix: timestamp cannot be negative")
    elif . == 0 then
      null
    elif . > 253402300799000 then
      error("fromunix: timestamp out of valid range")
    else
      if . > 9999999999 then
        (. / 1000 | todateiso8601)
      else
        todateiso8601
      end
    end
  elif . == null then
    null
  else
    error("fromunix: input must be number or null")
  end;
