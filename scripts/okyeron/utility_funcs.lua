-- utility functions

local function split_str(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

local function is_even(number)
  return number % 2 == 0
end

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


--strsub (s, i)

for i in io.popen("ls ~/dust/scripts/"):lines() do
  if string.find(i,"%.*$") then 
     print(i) 
  end
end