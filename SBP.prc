// parameters
DEFPARAM PRELOADBARS = 500

//flen = 401
flen=626
slen = 61

REM Money Management
Capital = 100000
Risk = 0.1
StopLoss = 100
REM Calculate contracts
equity = Capital + StrategyProfit
maxrisk = round(equity*Risk)

once maxPositionSize = 10
once Size = MAX(1,abs(round((maxrisk/StopLoss)/PointValue)*pipsize))
graph abs(round((maxrisk/StopLoss)/PointValue)*pipsize)
// Average Consecutive Wins
once countWins = 0
once aveConsecWins = 0
once countWinStreaks = 0

tradeJustClosed = (longOnMarket[1] and not longOnMarket) or (shortOnMarket[1] and not shortOnMarket)
lastTradeWon = positionPerf(1) > 0

if tradeJustClosed and lastTradeWon then
countWins = countWins + 1 // counting the number of wins in this streak

if countWins >= 2 AND countWins <= aveConsecWins then
Size = min(maxPositionSize, Size + 1) // increase risk
endif

elsif tradeJustClosed and not lastTradeWon then

if countWins >= 2 then // less than 2 is not a streak
countWinStreaks = countWinStreaks + 1 // increase count of winning streaks
totalWins = totalWins + countWins // total number of wins so far
aveConsecWins = totalWins / countWinStreaks // average consecutivie wins
endif

countWins = 0 // we lost - reset number of wins to zero
Size = MAX(1,abs(round((maxrisk/StopLoss)/PointValue)*pipsize))
endif
graph aveConsecWins coloured (10, 200, 10) as "ave consec wins"
graph countWins


if barindex>slen then
a1= 5/flen
a2= 5/slen
PB = (a1 - a2) * close + (a2*(1 - a1) - a1 * (1 - a2))* close[1] + ((1 - a1) + (1 - a2))*(PB[1])- (1 - a1)* (1 - a2)*(PB[2])
RMSa = summation[50](PB*PB)
RMSplus = sqrt(RMSa/50)
RMSminus = -RMSplus
endif
//
//GRAPH PB
//GRAPH RMSminus
//GRAPH RMSplus

// Conditions to enter long positions
IF NOT LongOnMarket AND (PB > RMSMinus AND PB[1] < RMSMinus)THEN
BUY Size CONTRACTS AT MARKET
ENDIF

// Conditions to exit long positions
If LongOnMarket AND ((PB < RMSPLus AND PB[1] > RMSPLus) OR (PB < RMSMinus AND PB[1] > RMSMinus)) THEN
SELL AT MARKET
ENDIF

// Conditions to enter short positions
IF NOT ShortOnMarket AND (PB < RMSPLus AND PB[1] > RMSPLus) THEN
SELLSHORT Size CONTRACTS AT MARKET
ENDIF

// Conditions to exit short positions
IF ShortOnMarket AND ((PB > RMSMinus AND PB[1] < RMSMinus) OR (PB > RMSPlus AND PB[1] < RMSPlus)) THEN
EXITSHORT AT MARKET
ENDIF

// Stops and targets : Enter your protection stops and profit targets here
