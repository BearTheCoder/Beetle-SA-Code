function ReadChatEvent(user, MyMessage)
  -- if (string.find(MyMessage, 'luckey7heart') == nil) then return end
  load();
  setProperty(data, 'MyMessage', 0);
  save();
  log(data.MyMessage);
end

return function()
  log('Update Status...'); --log is a SA function
  addEvent('chatMessage', 'ReadChatEvent');
  keepAlive();
end
