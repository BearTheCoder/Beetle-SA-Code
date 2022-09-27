Time = .05;

return function()
  log('Update Love Status Bar...'); -- check header (4)
  local app = getApp();
  local myObject = app.createGameObject();
  local pos = app.convertPercentToPosition(0.5, 0.5);
  myObject.setPosition(pos.x, pos.y);
  while true do
    applyImage(myObject, 'Scott 1');
    wait(Time);
    applyImage(myObject, 'Scott 2');
    wait(Time);
    applyImage(myObject, 'Scott 3');
    wait(Time);
    applyImage(myObject, 'Scott 4');
    wait(Time);
    applyImage(myObject, 'Scott 5');
    wait(Time);
    applyImage(myObject, 'Scott 6');
    wait(Time);
    applyImage(myObject, 'Scott 7');
    wait(Time);
    applyImage(myObject, 'Scott 8');
    wait(Time);
  end
end
