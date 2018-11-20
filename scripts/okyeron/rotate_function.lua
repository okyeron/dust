tbl = {
  "douche1",
  "douche2",
  "douche3",
  "douche4",
}

local function nextIndex(tbl, amount)
  local t = {}
  local i
  for k,v in ipairs(tbl) do
    i = k + amount
    if i <= #tbl then
      t[i] = v
    else
      t[i-#tbl] = v
    end
  end
  return t
end

local function rotate_new(t, rot, n, r)
  n, r = n or #t, {}
  rot = rot % n
  for i = 1, rot do
    r[i] = t[n - rot + i]
  end
  for i = rot + 1, n do
    r[i] = t[i - rot]
  end
  return r
end

tab.print (rotate_new(tbl, -1))