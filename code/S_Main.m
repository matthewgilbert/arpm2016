% Main script for running simulations and analytics

% load and parse quote and trade data
[quotes, quote_str] = xlsread('db_US_10yr_Future_quotes_and_trades.xlsx', 'quotes');
[trades, trade_str] = xlsread('db_US_10yr_Future_quotes_and_trades.xlsx', 'trades');

quote_flds = quote_str(1, 2:end);
trade_flds = trade_str(1, 2:end);

quote_time = datenum(quote_str(2:end, 1));
trade_time = datenum(trade_str(2:end, 1));


micro_prices = (quotes(:, 1) .* quotes(:, 5) + quotes(:, 4) .* quotes(:, 2)) ...
               ./ (quotes(:, 2) + quotes(:, 5));
mid_prices = (quotes(:, 1) + quotes(:, 4)) / 2;

% plot in clock time
figure
hold on
h1 = plot(quote_time, micro_prices);
h3 = plot(trade_time, trades(:, 1), 'kx');
h2 = plot_quotes(quote_time, quotes(:, [1, 2, 4, 5]));
datetick
title('US 10YR Future Order Book')
ylabel('Price')
xlabel('Wall Clock Time')
legend([h1, h2, h3], {'micro price', 'bid/ask', 'bid/ask size', 'trades'})


% create a superset and ticks for trades and quotes
all_time = sort([quote_time; trade_time]);
[~, quote_time_idx] = ismember(quote_time, all_time);
quote_tick_time = quote_time_idx / length(all_time);
[~, trd_time_idx] = ismember(trade_time, all_time);
trd_tick_time = trd_time_idx / length(all_time);

% plot in tick time
figure
hold on
h1 = plot(quote_tick_time, micro_prices);
h3 = plot(trd_tick_time, trades(:, 1), 'kx');
h2 = plot_quotes(quote_tick_time, quotes(:, [1, 2, 4, 5]));
title('US 10YR Future Order Book')
ylabel('Price')
xlabel('Tick Time')
legend([h1, h2, h3], {'micro price', 'bid/ask', 'bid/ask size', 'trades'})

% use for saving output in nice pdf format
%title('')
%print -painters -dpdf -r600 ticktime.pdf

% plot tick time mid price and micro price
figure
hold on
h1 = plot(quote_tick_time, micro_prices);
h2 = plot(quote_tick_time, mid_prices);
title('US 10YR Future Micro and Mid Prices')
ylabel('Price')
xlabel('Tick Time')
legend([h1, h2], {'micro price', 'mid price'})


% exogenous market impact analysis

% calculate price changes and signed size and transform to same size
% some trade signs are NaN which is likely since they cannot be identified
% fill these values in with 0

sum(isnan(trades(:, [2,3])))
sum(isnan(micro_prices))

trd_sign = trades(:, 3);
trd_sign(isnan(trd_sign)) = 0;

signed_size = zeros(size(all_time));
tmp = trades(:, 2) .* trd_sign;
% trades are lagged by 1
signed_size(trd_time_idx(2:end)) = tmp(1:end-1);

price_delta = zeros(size(all_time));
tmp = diff(micro_prices);
price_delta(quote_time_idx(2:end)) = tmp;

sum(isnan(price_delta))
sum(isnan(signed_size))

%%% investigate regressions with only trade ticks and with all ticks%%%%

[~, ~, resids] = regress(price_delta, signed_size);
figure
autocorr(resids)
title('Sample Autocorrlation Function with all quote and trade ticks')

[~, ~, resids] = regress(price_delta(trd_time_idx), signed_size(trd_time_idx));
figure
autocorr(resids)
title('Sample Autocorrlation Function with only trade ticks')

%%%% create lagged regressor and look at only trade ticks %%%%

tmp = trades(:, 2) .* trd_sign;
X_quotes = zeros(length(tmp), 10);
for i = 1:10
    X_quotes(i+1:end,i) = tmp(1:end-i);
end

price_delta_trds = price_delta(trd_time_idx);

% regression with lags and intercept
X = [ones(length(X_quotes), 1), X_quotes];
[beta2, beta_int2, resids2, ~, stats2] = regress(price_delta_trds, X);
figure
autocorr(resids)
stats2

% regression with intercept
[beta2b, beta_int2b, resids2b, ~, stats2b] = regress(price_delta_trds, X(:,[1,2]));
stats2b




