install.packages("quantmod")
install.packages("forecast")
install.packages("tseries")
library(quantmod)
library(forecast)
library(tseries)


# Input list of stocks
stock_tickers <- c("AAPL", "GOOG", "MSFT")



for (ticker in stock_tickers) {
  cat("\n   Forecast for:", ticker, "is: ")

  getSymbols(ticker, src = "yahoo", from = "2015-01-01", to = Sys.Date())
  stock_prices = Cl(get(ticker))

  
  best_model <- auto.arima(stock_prices)

  
  future_forecast <- forecast(best_model, h = 252)
  forecast_values <- future_forecast$mean
  average_forecast_value <- mean(forecast_values)
  last_close <- tail(stock_prices, 1)
  percentage_increase <- ((average_forecast_value - last_close) / last_close) * 100

  
  cat(round(percentage_increase, 2), "%")
}
