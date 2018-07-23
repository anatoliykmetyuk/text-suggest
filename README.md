# Usage
Select a text you'd like to replace. Press middle mouse key. Enter your replacement in the popup menu. The text gets replaced. Next time you want to replace the same text using middle mouse key, you'll have an option to select your old replacement from the popup menu.

# Installation
First, install and familiarize yourself with [Hammerspoon](https://www.hammerspoon.org/). Next, run the commands below. **Don't forget to reload the Hammerspoon config after the procedure!**.

```bash
HAMMERSPOON="~/.hammerspoon"

# Install dependencies
mkdir ~/.hammerspoon/lib
cd ~/.hammerspoon/lib
git clone https://github.com/kikito/inspect.lua.git inspect
git clone https://github.com/rxi/json.lua.git json
git clone https://github.com/ImLiam/Lua-Collections.git

# Install text-suggest
cd ~/.hammerspoon/Spoons
git clone https://github.com/anatoliykmetyuk/text-suggest.git
cd ~/.hammerspoon
echo "local ts = require(\"Spoons.text-suggest.suggest\")" >> init.lua
```
