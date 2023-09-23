-- -------------------------------
-- Watcher for changes of init.lua
-- -------------------------------
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- ------------------
-- Modifier shortcuts
-- ------------------

local moveWindowHyper = {"cmd", "alt"}
local moveFocusHyper = {"ctrl", "alt"}
local otherActionsHyper = {"cmd", "alt"}

-- Disable window animation:
hs.window.animationDuration = 0

-- ------------------
-- Window Movement
-- ------------------

function setWinFrame(win, frame)
    -- this func fixes grammerly issue: https://github.com/Hammerspoon/hammerspoon/issues/3224
    local axApp = hs.axuielement.applicationElement(win:application())
    local wasEnhanced = axApp.AXEnhancedUserInterface
    if wasEnhanced then
        axApp.AXEnhancedUserInterface = false
    end
    
    win:setFrame(frame)
    
    if wasEnhanced then
        axApp.AXEnhancedUserInterface = true
    end
end

hs.hotkey.bind(moveWindowHyper, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local screenRect = screen:frame()

  -- if linked to the left side of the screen, shrink it
  if f.x <= screenRect.x then 
    -- if the window size is half or less, try to move it to other screen
    if f.w <= screenRect.w / 2 then
    local displays = hs.screen.allScreens()
      local newScreen = displays[1] 
      local newScreenRect = newScreen:frame()
      
      -- resize to be half in that screen size
      f.w = newScreenRect.w / 2
      
      -- fix position to be in the most right side and not left
      f.x = newScreenRect.x + newScreenRect.w - f.w
      
      -- for now, when moving to other screen, it will always be in the max height we can
      f.y = newScreenRect.y
      f.h = newScreenRect.h
      setWinFrame(win, f)
      do return end
    end

    f.w = f.w / 2
    
    setWinFrame(win, f)
    do return end
  end

  -- if linked to the right side of the screen, make it bigger
  if f.x + f.w >= screenRect.x + screenRect.w then
    f.x = f.x - f.w
    f.w = f.w * 2
    
    setWinFrame(win, f)
    do return end
  end

  -- window not in pattern, move to the left side of the screen
  f.x = screenRect.x
  f.y = screenRect.y
  f.w = screenRect.w / 2
  f.h = screenRect.h

  setWinFrame(win, f)
end)

hs.hotkey.bind(moveWindowHyper, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local screenRect = screen:frame()

  -- if linked to the right side of the screen, shrink it
  if f.x + f.w >= screenRect.x + screenRect.w then
    -- if the window size is half or less, try to move it to other screen
    if f.w <= screenRect.w / 2 then
    local displays = hs.screen.allScreens()
      local newScreen = displays[2] 
      local newScreenRect = newScreen:frame()
      
      -- resize to be half in that screen size
      f.w = newScreenRect.w / 2
      
      -- fix position to be in the most right side and not left
      f.x = newScreenRect.x
      
      -- for now, when moving to other screen, it will always be in the max height we can
      f.y = newScreenRect.y
      f.h = newScreenRect.h
      setWinFrame(win, f)
      do return end
    end

    f.w = f.w / 2
    f.x = f.x + f.w

    setWinFrame(win, f)
    do return end
  end

  -- if linked to the left side of the screen, make it bigger
  if f.x <= screenRect.x then 
    f.w = f.w * 2
    
    setWinFrame(win, f)
    do return end
  end
  
  -- window not in pattern, move to the right side of the screen
  f.x = screenRect.x + (screenRect.w / 2)
  f.y = screenRect.y
  f.w = screenRect.w / 2
  f.h = screenRect.h
  setWinFrame(win, f)
end)

hs.hotkey.bind(moveWindowHyper, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local screenRect = screen:frame()

  -- if linked to the upper side of the screen, shrink it
  if f.y <= screenRect.y then
    f.h = f.h / 2

    setWinFrame(win, f)
    do return end
  end

  -- if linked to the down side of the screen, make it bigger
  if f.y + f.h >= screenRect.h then
    f.y = f.y - f.h
    f.h = f.h * 2

    setWinFrame(win, f)
    do return end
  end

  -- window not in pattern, move to the upper side of the screen
  f.x = screenRect.x
  f.y = screenRect.y
  f.w = screenRect.w
  f.h = screenRect.h / 2
  setWinFrame(win, f)
end)

hs.hotkey.bind(moveWindowHyper, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local screenRect = screen:frame()

  -- if linked to the down side of the screen, shrink it
  if f.y + f.h >= screenRect.h then
    f.h = f.h / 2
    f.y = f.y + f.h

    setWinFrame(win, f)
    do return end
  end

  -- if linked to the upper side of the screen, make it bigger
  if f.y <= screenRect.y then
    f.h = f.h * 2

    setWinFrame(win, f)
    do return end
  end

  -- window not in pattern, move to the down side of the screen
  f.x = screenRect.x
  f.y = screenRect.h / 2
  f.w = screenRect.w
  f.h = screenRect.h / 2
  setWinFrame(win, f)
end)

-- ------------------
-- Window Focus Change
-- ------------------
hs.hotkey.bind(moveFocusHyper, "Left", function()
    if hs.window.focusedWindow() then
        hs.window.focusedWindow():focusWindowWest(nil, true, false)
    else
        hs.alert.show("No active window")
    end
end)

hs.hotkey.bind(moveFocusHyper, "Right", function()
    if hs.window.focusedWindow() then
        hs.window.focusedWindow():focusWindowEast(nil, true, false)
    else
        hs.alert.show("No active window")
    end
end)

hs.hotkey.bind(moveFocusHyper, "Up", function()
    if hs.window.focusedWindow() then
        hs.window.focusedWindow():focusWindowNorth(nil, true, false)
    else
        hs.alert.show("No active window")
    end
end)

hs.hotkey.bind(moveFocusHyper, "Down", function()
	-- TODO: maybe check that the window.y + height is less than the screen height
    if hs.window.focusedWindow() then
        hs.window.focusedWindow():focusWindowSouth(nil, true, false)
    else
        hs.alert.show("No active window")
    end
end)

-- make window full screen, also good for inserting window into the grid
hs.hotkey.bind(otherActionsHyper, "return", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local screenRect = screen:frame()

  f.x = screenRect.x
  f.y = screenRect.y
  f.w = screenRect.w
  f.h = screenRect.h
  setWinFrame(win, f)
end)

-- ------------------
-- Other Stuff
-- ------------------

function moveWindowToDisplay(d)
  return function()
    local displays = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    win:moveToScreen(displays[d], false, true)
  end
end

hs.hotkey.bind(otherActionsHyper, "1", moveWindowToDisplay(1))
hs.hotkey.bind(otherActionsHyper, "2", moveWindowToDisplay(2))
hs.hotkey.bind(otherActionsHyper, "3", moveWindowToDisplay(3))

-- Programs HotKeys
local applicationHotkeys = {
  c = 'Google Chrome',
  u = 'Sublime Text',
  v = 'Visual Studio Code',
  i = 'iTerm',
  f = 'Firefox',
}

for key, app in pairs(applicationHotkeys) do
  hs.hotkey.bind(otherActionsHyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end
