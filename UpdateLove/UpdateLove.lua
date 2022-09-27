--[[
  ----- HEADER -----
  LUA SPECIFIC THINGS - MIGHT BE CONFUSING
  When using LUA global variables are the default unless specified otherwise with a "local" declaration. This is not dependant on SCOPE.

  SA SPECIFIC THINGS
  1.) load() - This SA function parses the "UpdateLove_settings.json" file to an object called "data". CANNOT BE USED ASYNC.
  2.) get() - This SA function parses the "UpdateLove_settings.json" and returns an object. CAN BE USED ASYNC.
  3.) set() - This SA function adds a field to the object specified. CAN BE USED ASNYC.
  4.) setProperty(data, 'Property', value) - This SA function adds a field to 'data' that can be parsed later. CANNOT BE USED ASYNC.
  5.) save() - This SA function saves the "data" object to the "UpdateLove_settings.json" file. NOT DEPENDANT ON THREAD.
  6.) log() - This SA function logs to the console and is used for debugging. The console can be found using 'CTRL+C' to access the command line.
    Type "lua" into the command line to access the debug console.
--]]

function LoadStatusBar()
  Pos = App.convertPercentToPosition(0.5, 0.25);
  MyObject.setPosition(Pos.x, Pos.y);
  load();
  local ImageName = 'HealthBar' .. data.Love;
  save();
  applyImage(MyObject, ImageName);
end

-- This event functions ASYNC
function ReadChatEvent(user, MyMessage)
  local mData = get('data');
  if (string.find(MyMessage, 'FillLovePlease') == nil) then
    if (mData.Love == 1) then return end
    mData.Love = mData.Love - 1;
    set('data', mData);
    save();
    goto FuncEnd;
  end
  if (mData.Love == 21) then return end
  mData.Love = mData.Love + 1;
  set('data', mData);
  save();
  ::FuncEnd::
  UpdateStatusBar();
end

-- This function is called inside of an event and must be treated as ASYNC.
function UpdateStatusBar()
  local mData = get('data')
  local mMyObject = get('MyObject')
  local ImageName = 'HealthBar' .. mData.Love;
  applyImage(mMyObject, ImageName);
end

-- Main Function
return function()
  App = getApp();
  MyObject = App.createGameObject();
  LoadStatusBar();
  addEvent('chatMessage', 'ReadChatEvent');
  keepAlive();
end
