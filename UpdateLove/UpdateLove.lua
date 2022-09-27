--[[
  HEADER
  1.) load() - This SA function parses the "UpdateLove_settings.json" file to and object called "data" that we can edit.
  2.) save() - This SA function saves the "data" object to the "UpdateLove_settings.json" file
  3.) setProperty(data, 'Property', value) - This SA CREATES a property that can be saved to the JSON file. This function is needed as "script wise" 
    the object 'data' doesn't exist and needs to be changed on the SA scale and not LUA scale.
  4.) log() - This SA function logs to the console and is used for debugging. The console can be found using 'CTRL+C' to access the command line.
    Type "lua" into the command line to access the debug console.
--]]

Love = nil;
App = nil;
MyObject = nil;

function LoadStatusBar()
  Pos = App.convertPercentToPosition(0.5, 0.5);
  MyObject.setPosition(Pos.x, Pos.y);
  local ImageName = 'HealthBar' .. Love;
  applyImage(MyObject, ImageName);
  log("Status bar loaded...");
end

function ReadChatEvent(user, MyMessage)
  log('Message recieved...');
  if (string.find(MyMessage, 'FillLovePlease') == nil) then
    log('Message contains nil value ...');
    if (Love == 1) then log('LOVE = 1, No adjustments...') return end
    Love = Love - 1;
    log('Removing 1 from LOVE...')
    return
  end
  if (Love == 21) then log('LOVE Equal to 21...'); return end
  Love = Love + 1;
  log('Adding one to LOVE...');
  log('Love: ' .. Love);
  UpdateStatusBar();
end

function UpdateStatusBar()
  local ImageName = 'HealthBar' .. Love;
  log(ImageName);
  applyImage(MyObject, ImageName);
  log("Status bar updated...")
end

return function()
  log('Status bar script loaded...');
  Love = 1;
  App = getApp();
  MyObject = App.createGameObject();
  LoadStatusBar();
  addEvent('chatMessage', 'ReadChatEvent');
  keepAlive();
end
