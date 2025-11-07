# Neutralize Indicators of Compromise (IOCs) for safe sharing
# Input: string (IP, URL, email, or domain)
# Output: string (defanged format) or null
def todefang:
  if type == "string" then
    if length == 0 then
      error("todefang: input string cannot be empty")
    else
      gsub("http"; "hxxp") |
      gsub("@"; "[@]") |
      gsub("\\."; "[.]")
    end
  elif . == null then
    null
  else
    error("todefang: input must be string or null")
  end;
