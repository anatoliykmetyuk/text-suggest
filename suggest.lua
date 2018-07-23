local collections = require("lib.Lua-Collections.collections")
local inspect     = require("lib.inspect.inspect")
local json        = require("lib.json.json")

local suggestionsFile = "suggest.json"

local function readAllSuggestions()
  local file = io.open(suggestionsFile, "r")
  local coln = collect()

  for l in file:lines() do coln:append(json.decode(l)) end

  file:close()
  return coln
end

local function readSuggestions(word)
  return readAllSuggestions()
    :filter(function (k, v) return v["word"] == string.lower(word) end)
    :map   (function (k, v) return k, v["suggestion"] end)
    :values()
end

local function writeSuggestion(wordRaw, suggestion)
  local word = string.lower(wordRaw)
  local newContent = readAllSuggestions()
    :filter(function (k, v) return not (v["word"] == word and v["suggestion"] == suggestion) end)
    :prepend({word = word, suggestion = suggestion})

  local file = io.open(suggestionsFile, "w")
  newContent:each(function (k, v) file:write(json.encode(v) .. '\n') end)
  file:close()
end

local function mkChoices(sgs, query)
  return sgs:map(function (k, v) return k, { ["text"] = v, ["query"] = query } end):values()
end

local function distinct(tbl, hashKey)
  local hash = {}
  local res  = {}

  for _,v in ipairs(tbl) do
    if (not hash[hashKey(v)]) then
      res[#res+1] = v
      hash[hashKey(v)] = true
    end
  end
  return res
end

local function spawnChooser(selected, allResults)
  local c = hs.chooser.new(function (sel)
    if sel ~= nil then
      writeSuggestion(sel["query"], sel["text"])
      hs.eventtap.keyStrokes(sel["text"])
    end
  end)

  local function setChoices(coll)
    c:choices(distinct(coll:all(), function (v) return v["text"] end))
  end

  local suggestions
  if not allResults then suggestions = readSuggestions(selected)
  else suggestions = readAllSuggestions()
    :map(function (k, v) return k, v["suggestion"] end):values()
  end
  
  local choices = mkChoices(suggestions, selected)

  setChoices(choices)
  c:queryChangedCallback(function (q)
    if string.len(q) > 0 then setChoices(choices
      :clone()
      :filter(function (k, v) return string.match(v["text"], q) ~= nil end)
      :prepend({ ["text"] = q, ["query"] = selected })
      :values())
    else setChoices(choices) end
  end)
  c:show()
end

local function main(allResults)
  hs.eventtap.keyStroke({"cmd"}, "C")
  hs.timer.doAfter(0.05, function ()
    local selected = hs.pasteboard.readString()
    spawnChooser(selected, allResults)
  end)
end

hs.eventtap.new({hs.eventtap.event.types.middleMouseUp}, function (evt)
  hs.timer.doAfter(0.05, main)
  return true
end):start()

hs.hotkey.bind({"alt"}, "R", function() main(true) end)

-- local sgs = mkChoices(readAllSuggestions():map(function (k, v) return k, v["suggestion"] end):values(), "foo")
-- local sgsTbl = sgs
--   :clone()
--   :prepend({ ["text"] = "Custom Stuff", ["query"] = "Custom Stuff" })
--   :values()
--   :all()

-- print(inspect(distinct(sgsTbl, function(v) return v["text"] end)))
