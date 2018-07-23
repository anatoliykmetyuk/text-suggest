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

local function spawnChooser(selected)
  local c = hs.chooser.new(function (selected)
    writeSuggestion(selected["query"], selected["text"])
    hs.eventtap.keyStrokes(selected["text"])
  end)

  local choices = mkChoices(readSuggestions(selected), selected)

  c:choices(choices:all())
  c:queryChangedCallback(function (q)
    if string.len(q) > 0 then c:choices(choices
      :clone()
      :filter(function (k, v) return string.match(v["text"], q) ~= nil end)
      :prepend({ ["text"] = q, ["query"] = selected })
      :all())
    else c:choices(choices:all()) end
  end)
  c:show()
end

hs.hotkey.bind({"alt"}, "R", function()
  hs.eventtap.keyStroke({"cmd"}, "C")
  hs.timer.doAfter(0.05, function ()
    local selected = hs.pasteboard.readString()
    spawnChooser(selected)
  end)
end)

