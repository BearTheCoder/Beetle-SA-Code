ParticipationTime = 120
UsersParticipating = {}
-- Needs to be deleted later
DefaultPlayerCount = 4;

function SendChatMessage()
  ChatMsg = 'A poker hand is being dealt! Use command !deal '
      .. '{amount} to be dealt a hand!';
  writeChat(ChatMsg);
  getChatMessages(ParticipationTime, readChat);
  ShuffleCards();
end

function readChat(user, msg)
  if string.find(msg, "!deal") then


    CanAddToList = true;
    for i = 1, #UsersParticipating, 1 do
      if string.find(UsersParticipating[i], user.displayName) then
        CanAddToList = false;
        break;
      end
    end
    if CanAddToList then
      table.insert(UsersParticipating, user.displayName);
    end
  end
end

function ShuffleCards()
  local Values = { 'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K' }
  local Suits = { 'h', 'c', 's', 'd' }
  local DealtCards = {}
  local Counter = 1000;
  for i = 1, Counter, 1 do
    local AddCard = true
    local Value = Values[math.random(1, #Values)];
    local Suit = Suits[math.random(1, #Suits)];
    local Card = Value .. Suit;
    for j, LocalCard in ipairs(DealtCards) do
      if LocalCard == Card then
        AddCard = false;
        break;
      end
    end
    if AddCard == true then
      table.insert(DealtCards, Card);
    end
    if (#DealtCards == (DefaultPlayerCount * 5)) then
      break;
    end
  end
  DealCards(DealtCards);
end

function DealCards(LocalDealtCards)
  local DealtHands = {}
  for i = 1, DefaultPlayerCount, 1 do
    local Hand = '';
    for j = 1, 5, 1 do
      local RandNum = math.random(1, #LocalDealtCards);
      if Hand == '' then
        Hand = LocalDealtCards[RandNum];
      else
        Hand = Hand .. ' ' .. LocalDealtCards[RandNum];
      end
      table.remove(LocalDealtCards, RandNum);
    end
    table.insert(DealtHands, Hand);
  end
  AnalyzeHand(DealtHands);
end

function AnalyzeHand(LocalDealtHands)
  local Score;
  local HighCard;
  local StraightType;
  local isFlush;
  for i = 1, #LocalDealtHands, 1 do
    local LocalSuits = {}
    local Values_F_AH = {}
    local LocalCards = {}
    for LocalCard in string.gmatch(LocalDealtHands[i], '([^%s]+)') do
      table.insert(LocalCards, LocalCard);
    end
    for i, LocalCard in ipairs(LocalCards) do
      if #LocalCard == 3 then
        table.insert(LocalSuits, string.sub(LocalCard, 3, 3))
        table.insert(Values_F_AH, '10');
      else
        table.insert(LocalSuits, string.sub(LocalCard, 2, 2))
        table.insert(Values_F_AH, string.sub(LocalCard, 1, 1));
      end
    end
    local SortedValues = SortValues(Values_F_AH);
    StraightType, Score, HighCard = CheckForStraight(SortedValues, Score, HighCard);
    isFlush, Score, HighCard = CheckForFlush(LocalSuits, Score, HighCard);
    if StraightType == 'Royal Straight' and isFlush then
      Score = 9;
      HighCard = nil;
      goto continue;
    elseif StraightType == 'Straight' and isFlush then
      Score = 8;
      goto continue;
    end
    Score, HighCard = CheckFor4OAK(SortedValues, Score, HighCard);
    if (Score == 7) then goto continue; end
    Score, HighCard = CheckForFullHouse(SortedValues, Score, HighCard);
    if (Score ~= nil) then goto continue; end
    Score, HighCard = CheckFor3OFK(SortedValues);
    if (Score ~= nil) then goto continue; end
    Score, HighCard = CheckForTwoPair(SortedValues);
    if (Score ~= nil) then goto continue; end
    Score, HighCard = CheckForPair(SortedValues);
    if (Score ~= nil) then goto continue; end
    if (Score == nil) then Score = 0
      HighCard = SortedValues[5]
    end
    ::continue::
    LocalDealtHands[i] = FormatHandForFiltering(LocalDealtHands[i], Score, HighCard)
    Score = nil;
  end
  FindWinner(LocalDealtHands);
end

function SortValues(LocalValues_P)
  local Values_F_SV = {}
  for i, Card in ipairs(LocalValues_P) do
    if Card == 'A' then table.insert(Values_F_SV, 14);
    elseif Card == 'K' then table.insert(Values_F_SV, 13);
    elseif Card == 'Q' then table.insert(Values_F_SV, 12);
    elseif Card == 'J' then table.insert(Values_F_SV, 11);
    else table.insert(Values_F_SV, tonumber(Card));
    end
  end
  table.sort(Values_F_SV);
  return Values_F_SV;
end

function CheckForStraight(CurrentValues, CurrentScore, CurrentHighCard)
  local isStraight = true;
  for i, Value in ipairs(CurrentValues) do
    if (CurrentValues[i + 1] ~= nil) then
      if (Value ~= (CurrentValues[i + 1] - 1)) then
        isStraight = false;
        return '', CurrentScore, CurrentHighCard;
      end
    end
  end
  if isStraight == true then
    if CurrentValues[5] == 14 then
      return 'Royal Straight', nil, nil;
    else
      return 'Straight', 4, CurrentValues[5];
    end
  elseif CurrentValues[1] == 2 and CurrentValues[2] == 3 and CurrentValues[3] == 4 and CurrentValues[4] == 5 and
      CurrentValues[5] == 14 then
    return 'Straight', 4, CurrentValues[4];
  end
end

function CheckForFlush(CurrentSuits, CurrentScore, CurrentHighCard)
  local isHandFlush = true;
  local FirstSuitInHand = CurrentSuits[1];
  for i, CurrentSuit in ipairs(CurrentSuits) do
    if CurrentSuit ~= FirstSuitInHand then
      isHandFlush = false;
      return false, CurrentScore, CurrentHighCard;
    end
  end
  if isHandFlush then
    return true, 5;
  end
end

function CheckFor4OAK(CurrentValues, CurrentScore, CurrentHighCard)
  if CurrentValues[2] ~= CurrentValues[3] then
    return CurrentScore, CurrentHighCard
  elseif CurrentValues[1] == CurrentValues[2] and
      CurrentValues[2] == CurrentValues[3] and
      CurrentValues[3] == CurrentValues[4] then
    return 7, CurrentValues[4]
  elseif CurrentValues[2] == CurrentValues[3] and
      CurrentValues[3] == CurrentValues[4] and
      CurrentValues[4] == CurrentValues[5] then
    return 7, CurrentValues[5]
  end
end

function CheckForFullHouse(CurrentValues, CurrentScore, CurrentHighCard)
  if CurrentValues[1] == CurrentValues[2] and CurrentValues[2] == CurrentValues[3] then
    if CurrentValues[4] == CurrentValues[5] then
      return 6, CurrentValues[5];
    end
  elseif CurrentValues[1] == CurrentValues[2] then
    if CurrentValues[3] == CurrentValues[4] and CurrentValues[4] == CurrentValues[5] then
      return 6, CurrentValues[5];
    end
  else
    return CurrentScore, CurrentHighCard;
  end
end

function CheckFor3OFK(CurrentValues)
  for i = 1, #CurrentValues, 1 do
    local CardCount = 0;
    for j = 1, #CurrentValues, 1 do
      if CurrentValues[i] == CurrentValues[j] then
        CardCount = CardCount + 1;
      end
    end
    if CardCount == 3 then
      return 3, CurrentValues[i];
    end
  end
end

function CheckForTwoPair(CurrentValues)
  Card1 = nil;
  for i = 1, #CurrentValues, 1 do
    local CardCount = 0;
    for j = 1, #CurrentValues, 1 do
      if CurrentValues[i] == CurrentValues[j] then
        if Card1 == nil then
          CardCount = CardCount + 1;
        elseif CurrentValues[i] ~= Card1 then
          CardCount = CardCount + 1;
        end
      end
    end
    if CardCount == 2 and Card1 == nil then
      Card1 = CurrentValues[i];
    elseif CardCount == 2 and Card1 ~= nil then
      return 2, CurrentValues[i];
    end
  end
end

function CheckForPair(CurrentValues)
  for i = 1, #CurrentValues, 1 do
    local CardCount = 0;
    for j = 1, #CurrentValues, 1 do
      if CurrentValues[i] == CurrentValues[j] then
        CardCount = CardCount + 1;
      end
    end
    if CardCount == 2 then
      return 1, CurrentValues[i];
    end
  end
end

function FormatHandForFiltering(CurrentHand, CurrentScore, CurrentHighCard)
  local FormattedString = ''
  local FormattedHighCard = nil;
  if CurrentHighCard == 10 then FormattedHighCard = '0';
  elseif CurrentHighCard == 11 then FormattedHighCard = 'J';
  elseif CurrentHighCard == 12 then FormattedHighCard = 'Q';
  elseif CurrentHighCard == 13 then FormattedHighCard = 'K';
  elseif CurrentHighCard == 14 then FormattedHighCard = 'A';
  else FormattedHighCard = tostring(CurrentHighCard); end
  FormattedString = CurrentScore .. ' ' .. FormattedHighCard .. ' ' .. CurrentHand
  return FormattedString;
end

function FindWinner(CurrentHands)
  table.sort(CurrentHands);
  local TopHand = string.sub(CurrentHands[#CurrentHands], 1, 1)
  local MatchingScore = 0;
  local MatchingHands = {}
  for i = 1, #CurrentHands, 1 do
    if string.sub(CurrentHands[i], 1, 1) == TopHand then
      MatchingScore = MatchingScore + 1;
      table.insert(MatchingHands, CurrentHands[i])
    end
  end
  if MatchingScore ~= 0 then
    local SortedByHighCard = {}
    for i = 1, #MatchingHands, 1 do
      local FormattedString = ''
      local FormattedHighCard = nil;
      if string.sub(MatchingHands[i], 3, 3) == 'A' then FormattedHighCard = 14;
      elseif string.sub(MatchingHands[i], 3, 3) == 'K' then FormattedHighCard = 13;
      elseif string.sub(MatchingHands[i], 3, 3) == 'Q' then FormattedHighCard = 12;
      elseif string.sub(MatchingHands[i], 3, 3) == 'J' then FormattedHighCard = 11;
      elseif string.sub(MatchingHands[i], 3, 3) == '0' then FormattedHighCard = 10;
      else FormattedHighCard = '0 ' .. string.sub(MatchingHands[i], 3, 3); end
      FormattedString = FormattedHighCard .. ' ' .. string.sub(MatchingHands[i], 5)
      table.insert(SortedByHighCard, FormattedString);
    end
    table.sort(SortedByHighCard);
    log('WINNING HAND: ' .. string.sub(SortedByHighCard[#SortedByHighCard], 4))
  else
    log('WINNING HAND: ' .. string.sub(CurrentHands[#CurrentHands], 5))
  end

  --Not Necessary, Delete later vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  for i = 1, #CurrentHands, 1 do
    log(CurrentHands[i]);
  end
  --end
end

return function()
  SendChatMessage();
end
