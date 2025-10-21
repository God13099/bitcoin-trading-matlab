function final_balance = report(csvfilename, startday)
% REPORT Executes the Bitcoin trading strategy and generates a report

% === Read data ===
data = readtable(csvfilename, 'VariableNamingRule','preserve');

% Convert columns to numeric
priceCols = {'Price','High','Low','Open'};
for k = 1:length(priceCols)
    col = priceCols{k};
    if iscell(data.(col)) || isstring(data.(col))
        data.(col) = strrep(string(data.(col)), ",", "");
        data.(col) = str2double(data.(col));
    end
end

% Fix date format
if ~isdatetime(data.Date)
    try
        data.Date = datetime(data.Date, 'InputFormat', 'MM/dd/yyyy');
    catch
        data.Date = datetime(data.Date, 'InputFormat', 'yyyy-MM-dd');
    end
end

data = sortrows(data, 'Date', 'ascend');  % Sort by date ascending

% === Strategy parameters ===
params.atrN = 14;
params.breakoutN = 5;
params.highATR_mult = 2.0;
params.lowATR_mult = 1.0;
params.minHoldBTC = 0;

% === Initial wallet ===
usd = 0;
btc = 5.0;
n = height(data);

usd_hist = zeros(n,1);
btc_hist = zeros(n,1);
trade_log = {};

% === Trading loop ===
for i = startday:n
    [sellUSD, sellBTC] = mymethod(data, i, usd, btc, params);
    p = data.Price(i);

    % Buy
    if sellUSD > 0 && usd >= sellUSD
        qty = sellUSD / p;
        usd = usd - sellUSD;
        btc = btc + qty;
        trade_log = [trade_log; {data.Date(i), 'BUY', sellUSD, qty, p}];
    end

    % Sell
    if sellBTC > 0 && btc >= sellBTC
        usd = usd + sellBTC * p;
        btc = btc - sellBTC;
        trade_log = [trade_log; {data.Date(i), 'SELL', sellBTC*p, sellBTC, p}];
    end

    usd_hist(i) = usd;
    btc_hist(i) = btc;
end

% === Calculate daily total BTC value ===
daily_balance = btc_hist + usd_hist ./ data.Price;

% === Print daily balance ===
fprintf('\n--- Wallet balance per day (BTC value) ---\n');
for i = startday:n
    fprintf('%s : %.4f BTC\n', string(data.Date(i)), daily_balance(i));
end

% === Final balance ===
final_balance = daily_balance(end);
fprintf('\nFinal BTC balance: %.4f BTC\n', final_balance);
fprintf('Final USD value (converted): %.2f USD\n\n', final_balance * data.Price(end));

% === Plot results ===
figure;
plot(data.Date, data.Price, 'k', 'LineWidth', 1.2); hold on;
title('Bitcoin Strategy Execution');
xlabel('Date'); ylabel('Price (USD)');

if ~isempty(trade_log)
    T = cell2table(trade_log, ...
        'VariableNames', {'Date','Action','USD_Value','BTC_Qty','Price'});
    buyIdx = strcmp(T.Action,'BUY');
    sellIdx = strcmp(T.Action,'SELL');
    scatter(T.Date(buyIdx), T.Price(buyIdx), 40, 'r', 'filled');
    scatter(T.Date(sellIdx), T.Price(sellIdx), 40, 'g', 'filled');
    legend({'Price','Buy','Sell'});
else
    legend({'Price'});
end

saveas(gcf, 'strategy.jpg');
disp('Strategy plot saved as strategy.jpg');
end
