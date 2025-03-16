install.packages("quantmod")
install.packages("forecast")
install.packages("tseries")
library(quantmod)
library(forecast)
library(tseries)



# DATA

# Download stock price data from Yahoo Finance
getSymbols("AAPL", src = "yahoo", from = "2015-01-01", to = Sys.Date())

# Extract closing prices for the stock
stock_prices = Cl(AAPL)

# Plot stock prices (Optional)
plot(stock_prices, main="AAPL Stock Price", col="blue", lwd=2)


# ARIMA Selection

# Find the best ARIMA model
best_model <- auto.arima(stock_prices)

# Print model summary (Optional)
summary(best_model)


# FORECASTING

# Forecast for 252 trading days (1 year)
forecast_steps <- 252
future_forecast <- forecast(best_model, h = forecast_steps)

# Plot forecast (Optional)
plot(future_forecast, main="Stock Price Forecast for Next Year", col="red", lwd=2)

# Extract forecasted values
forecast_values <- future_forecast$mean
average_forecast_value <- mean(forecast_values)

# Get the last closing price for today
last_close <- tail(stock_prices, 1)

# Calculate percentage increase
percentage_increase <- ((average_forecast_value - last_close) / last_close) * 100

cat("Average Forecast Value for the next 1 year:", round(average_forecast_value, 2), "\n")
cat("Percentage Increase for the next 1 year:", round(percentage_increase, 2), "%\n")
