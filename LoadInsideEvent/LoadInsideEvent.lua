function ReadChatMsg(user, message)
  log(message);
  local mData = get('data');
  log(mData.Test);
end

function CallData()
  local mData = get('data');
  log(mData.Test);
end

return function()
  log('Connected...');
  load();
  CallData();
  addEvent('chatMessage', 'ReadChatMsg');
  keepAlive();
end
