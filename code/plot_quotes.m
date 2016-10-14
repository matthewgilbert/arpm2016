function h = plot_quotes(time, quote_data)
    % time -- vector for axis for plot
    % quote_data -- matrix t x 4 of bid price, bid size, ask price, and ask size
    % Returns
    % h - a vector of plot handles, bid/ask and size
    
    lgray = [0.8 0.8 0.8];
    
    magnitude = (max(quote_data(:, 1)) - min(quote_data(:, 1))) / 4;
    % scale size to be compatible with price in plot for visualizing
    SCL = max(quote_data(:, 2)) / magnitude;
    % small offset from bid and ask used for size plot
    eps = median(quote_data(:, 3) - quote_data(:, 1)) / 8;
    
    bid_lb = quote_data(:, 1) - eps - quote_data(:, 2) / SCL;
    bid_ub = quote_data(:, 1) - eps;
    
    ask_lb = quote_data(:, 3) + eps;
    ask_ub = quote_data(:, 3) + eps + quote_data(:, 4) / SCL;
    
    bid_band = [bid_lb, bid_ub];
    ask_band = [ask_lb, ask_ub];
    
    hold on
    h1 = plot(time, quote_data(:, [1, 3]), 'r');
    h2 = plot(time, [bid_ub, ask_lb], 'Color', lgray);
    
    for i = 1:length(time)
        t = time(i);
        line([t t], bid_band(i, :), 'Color', lgray, 'LineWidth', 3);
        line([t t], ask_band(i, :), 'Color', lgray, 'LineWidth', 3);
    end
    
    hold off
    h = [h1(1), h2(1)];

end