function [sellUSD, sellBTC] = mymethod(data, day, usd_amount, btc_amount, params)
% MYMETHOD_AGGRESSIVE_OPTIMIZED 
% Strikes a balance between stability and profitability

sellUSD = 0;
sellBTC = 0;

% --- Parameters ---
atrN = params.atrN;           
breakoutN = params.breakoutN; 
highATR_mult = params.highATR_mult;
lowATR_mult = params.lowATR_mult;
minHoldBTC = params.minHoldBTC;

% --- Safety check ---
if day <= max(atrN, breakoutN)
    return;
end

Close = data.Price;
High  = data.High;
Low   = data.Low;
priceNow = Close(day);  % Define priceNow here

% --- Calculate ATR and momentum indicator ---
TR = zeros(atrN,1);
for j = 1:atrN
    idx = day - j + 1;
    prevClose = Close(max(idx-1,1));
    TR(j) = max([High(idx)-Low(idx), abs(High(idx)-prevClose), abs(Low(idx)-prevClose)]);
end
ATR = mean(TR);

% Calculate momentum indicator
if day > 5
    momentum_5 = (priceNow - Close(day-5)) / Close(day-5);
else
    momentum_5 = 0;
end

% --- Dynamic breakout levels ---
recentHigh = max(High(day-breakoutN+1:day));
recentLow  = min(Low(day-breakoutN+1:day));

% --- Dynamic price slope ---
if day > 10
    recentSlope = (priceNow - Close(day-10)) / 10;
else
    recentSlope = 0;
end

% --- Optimized deterministic factors ---
% Combine multiple price features to create a more diverse "pseudo-random" pattern
price_fraction = mod(priceNow, 1);
high_low_range = (High(day) - Low(day)) / priceNow;
volume_signal = mod(day * 7 + price_fraction * 100, 1);  % Time-based periodic signal

% Combine deterministic factors
deterministic_factor1 = mod(price_fraction * 1000 + day, 1);
deterministic_factor2 = mod(high_low_range * 500 + day * 3, 1);
deterministic_factor = mod(deterministic_factor1 + deterministic_factor2 + volume_signal, 1);

% --- Enhanced buy conditions ---
if (priceNow < recentLow - lowATR_mult*ATR && usd_amount > 0) || ...
   (recentSlope > 0 && priceNow < recentLow + 0.3*ATR)
    
    % Higher base position
    base_fraction = 0.95;  % Increase base position to 95%
    
    % Dynamic adjustment based on signal strength
    oversold_degree = (recentLow - priceNow) / ATR;
    
    % Signal strength enhancement (more aggressive)
    if oversold_degree > 2.5
        strength_boost = 0.08;  % Extremely oversold +8%
    elseif oversold_degree > 2.0
        strength_boost = 0.05;  % Strongly oversold +5%
    elseif oversold_degree > 1.5
        strength_boost = 0.03;  % Moderately oversold +3%
    else
        strength_boost = 0.01;  % Slightly oversold +1%
    end
    
    % Momentum enhancement (new addition)
    if momentum_5 > 0.02
        momentum_boost = 0.03;  % Positive momentum +3%
    else
        momentum_boost = 0;
    end
    
    % Deterministic fine-tuning (broader range)
    deterministic_adjust = 0.06 * (deterministic_factor - 0.5);  % ±3% adjustment
    
    % Final position size
    invest_fraction = base_fraction + strength_boost + momentum_boost + deterministic_adjust;
    invest_fraction = min(1.0, max(0.88, invest_fraction));  % Between 88%–100%
    
    % Special case: extremely oversold + positive momentum = full position
    if oversold_degree > 2.5 && momentum_5 > 0.03
        invest_fraction = 1.0;
    end
    
    sellUSD = usd_amount * invest_fraction;
    return;
end

% --- Enhanced sell conditions ---
if (priceNow > recentHigh + highATR_mult*ATR && btc_amount > minHoldBTC) || ...
   (recentSlope < 0 && priceNow > recentHigh - 0.2*ATR)
    
    sellable = btc_amount - minHoldBTC;
    
    % Higher base sell ratio (more aggressive)
    base_sell_fraction = 0.85;  % Increase base sell ratio to 85%
    
    % Overbought enhancement
    overbought_degree = (priceNow - recentHigh) / ATR;
    
    if overbought_degree > 2.5
        overbought_boost = 0.12;  % Extremely overbought +12%
    elseif overbought_degree > 2.0
        overbought_boost = 0.08;  % Strongly overbought +8%
    elseif overbought_degree > 1.5
        overbought_boost = 0.04;  % Moderately overbought +4%
    else
        overbought_boost = 0.01;  % Slightly overbought +1%
    end
    
    % Negative momentum enhancement
    if momentum_5 < -0.02
        momentum_penalty = 0.06;  % Negative momentum +6%
    else
        momentum_penalty = 0;
    end
    
    % Deterministic fine-tuning
    deterministic_adjust = 0.08 * (deterministic_factor - 0.5);  % ±4% adjustment
    
    % Final sell ratio
    sell_fraction = base_sell_fraction + overbought_boost + momentum_penalty + deterministic_adjust;
    sell_fraction = min(1.0, max(0.75, sell_fraction));  % Between 75%–100%
    
    % Special case: extremely overbought + negative momentum = sell all
    if overbought_degree > 2.5 && momentum_5 < -0.03
        sell_fraction = 1.0;
    end
    
    sellBTC = max(0, sellable * sell_fraction);
    return;
end

% --- Optimized stop-loss logic ---
if priceNow < recentLow - 1.5*ATR && btc_amount > minHoldBTC
    % Momentum-based smart stop loss
    if momentum_5 < -0.04
        stop_loss_fraction = 0.90;  % Strong negative momentum: 90% stop loss
    elseif momentum_5 < -0.02
        stop_loss_fraction = 0.80;  % Moderate negative momentum: 80% stop loss
    else
        stop_loss_fraction = 0.70;  % Weak negative momentum: 70% stop loss
    end
    
    % Oversold adjustment: reduce stop loss when deeply oversold (avoid selling at bottom)
    oversold_degree = (recentLow - priceNow) / ATR;
    if oversold_degree > 2.0
        stop_loss_fraction = stop_loss_fraction * 0.8;  % Reduce stop loss when extremely oversold
    end
    
    sellBTC = max(0, (btc_amount - minHoldBTC) * stop_loss_fraction);
end

end
