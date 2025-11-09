# Convert macOS Cocoa/Core Foundation timestamp to ISO 8601
# Input: number (seconds since 2001-01-01 00:00:00 UTC)
# Output: string (ISO 8601 format) or null
def fromcocoa:
  if type == "number" then
    if . < -978307200 then
      error("fromcocoa: timestamp cannot be before Unix epoch")
    elif . > 252423993599 then
      error("fromcocoa: timestamp out of valid range")
    else
      (. + 978307200) | todateiso8601
    end
  elif . == null then
    null
  else
    error("fromcocoa: input must be number or null")
  end;
