# Restore defanged IOCs to their original format
# Input: string (defanged IP, URL, email, or domain)
# Output: string (original format) or null
def fromdefang:
  if type == "string" then
    if length == 0 then
      error("fromdefang: input string cannot be empty")
    else
      gsub("hxxp"; "http") |
      gsub("\\[@\\]"; "@") |
      gsub("\\[\\.\\]"; ".")
    end
  elif . == null then
    null
  else
    error("fromdefang: input must be string or null")
  end;
