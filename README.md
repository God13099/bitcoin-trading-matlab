# bitcoin-trading-matlab
Automated Bitcoin trading strategy in MATLAB using ATR and momentum signals
## 📈 Bitcoin Trading Strategy (MATLAB)

This project implements an automated Bitcoin trading strategy in MATLAB, based on ATR breakout, momentum, and deterministic pseudo-random factors to simulate adaptive trading behavior.

## 🧩 Files
File	Description
report.m	Main function that executes the trading strategy, plots results, and prints daily balances.
mymethod.m	Core decision logic that determines buy/sell amounts each day.
bitcoin.csv	Historical Bitcoin price dataset used for backtesting.
strategy.jpg	Automatically generated chart showing trades (buy/sell markers).

## 🚀 How to Run

Open MATLAB and navigate to this project folder.

Run the following command:

final_balance = report('bitcoin.csv', 20);


## The script will:

Read and clean Bitcoin price data

Execute daily trading decisions

Print wallet balances

Save a chart as strategy.jpg

## ⚙️ Strategy Logic

ATR-based breakout detection

Momentum signal (5-day lookback)

Dynamic position sizing

Deterministic pseudo-random adjustment

Smart stop-loss with oversold protection

## 📊 Output Example
--- Wallet balance per day (BTC value) ---
09/04/2021 : 5.6131 BTC
09/05/2021 : 5.6131 BTC
...
Final BTC balance: 7.4284 BTC
Final USD value (converted): 823587.40 USD

## Author

Liyuan Cao
SGH Warsaw School of Economics
Email: caoliyuan07@163.com
Date: October 2025
