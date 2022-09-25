function BeetleBlockEvent(user, block)
  log(block.id .. ' ' .. type(block.id));
  if block.id == 1 then
    runCommand('!change ' .. user.displayName .. ' !jump');
  end
end

return function()
  addEvent('scriptableBlocks', 'BeetleBlockEvent');
  keepAlive();
end