function ReadChatMsg(user, message)
  log(message);
  log(data.Test);
end

function CallData()
  log(data.Test);
end

return function()
  log('Connected...');
  load();
  CallData();
  addEvent('chatMessage', 'ReadChatMsg');
  keepAlive();
end
