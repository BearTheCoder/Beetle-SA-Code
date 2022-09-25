--[[
  HEADER
  1.) load() - This SA function parses the "UpdateLove_settings.json" file to and object called "data" that we can edit.
  2.) save() - This SA function saves the "data" object to the "UpdateLove_settings.json" file
  3.) setProperty(data, 'Property', value) - This SA CREATES a property that can be saved to the JSON file. This function is needed as "script wise" 
    the object 'data' doesn't exist and needs to be changed on the SA scale and not LUA scale.
  4.) log() - This SA function logs to the console and is used for debugging. The console can be found using 'CTRL+C' to access the command line.
    Type "lua" into the command line to access the debug console.
--]]


function DetectDataLove()
  load(); -- check header (1)
  if (data.Love ~= nil) then return end
  setProperty(data, 'Love', 0); -- check header (3)
  save(); -- check header (2)
end

function ReadChatEvent(user, MyMessage)
  log(MyMessage);
end

return function()
  log('Update Love Status Bar...'); -- check header (4)
  DetectDataLove();
  addEvent('chatMessage', 'ReadChatEvent');
  keepAlive();
end
