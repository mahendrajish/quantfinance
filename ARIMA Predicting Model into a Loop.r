install.packages("quantmod")
install.packages("forecast")
install.packages("tseries")
library(quantmod)
library(forecast)
library(tseries)


# Define a list of stock tickers you want to predict returns for
tickers <- c("PG", "KO", "PEP", "JNJ", "CL", "UL", 
                   "GIS", "KMB", "MDLZ", "COLM", "EL", "MCD", 
                   "PM", "HSY", "CAG", "LRLCF", "KHC", "OR", "BN", "7203.T", 
                   "005930.KS", "066570.KS", "CX", "BABA", "AMZN", 
                   "TGT", "WMT", "COST", "TJX", "LOW", 
                   "NKE", "SBUX", "K")


# Function to get price of stock of on any day

get_closest_price <- function(stock_prices, target_date) {
  closest_index <- which.min(abs(index(stock_prices) - target_date))
  return(as.numeric(stock_prices[closest_index]))
}





# Loop


for (ticker in tickers) {
  cat("\n   Forecast for:", ticker, "is: ")

  
  
  # DATA
  
  getSymbols(ticker, src = "yahoo", from = "2010-01-01", to = Sys.Date())
  stock_prices = Cl(get(ticker))
  arima.data <- tail(stock_prices, 252 * 2) 

  
  
  # Assess General Trend
  
  y10 <- get_closest_price(stock_prices,Sys.Date()-364*10)
  y8 <- get_closest_price(stock_prices,Sys.Date()-364*8)
  y6 <- get_closest_price(stock_prices,Sys.Date()-364*6)
  ynow <-get_closest_price(stock_prices,Sys.Date())  # Current stock price
  y2 <- get_closest_price(stock_prices,Sys.Date()-364*2)
  y4 <- get_closest_price(stock_prices,Sys.Date()-364*4)
  
  first.avg <- mean(c(y10,y8,y6), na.rm = TRUE)
  second.avg <- mean(c(ynow,y2,y4), na.rm = TRUE)

  if (first.avg > second.avg) {
    trend <- "Down"
  } else {
    trend <- "Up"
  }
  

  
  # ARIMA Selection
  
  best_model <- auto.arima(arima.data)

  
  
  # FORECASTING
  
  future_forecast <- forecast(best_model, h = 252)
  
  forecast_values <- future_forecast$mean
  average_forecast_value <- mean(forecast_values)
  last_close <- tail(arima.data, 1)
  
  percentage_increase <- ((average_forecast_value - last_close) / last_close) * 100
  

  
  # FORECAST CHECK - We use upper or lower bound, according to stock trend, if forecast is not sufficient
  
  if (percentage_increase >= -1 && percentage_increase <= 1) {
    cat("[]  ")
    
    if (trend == "Up") {
      upper_bound_forecast <- future_forecast$upper[, 2]
      average_forecast_value <- mean(upper_bound_forecast)
    } else {
      lower_bound_forecast <- future_forecast$lower[, 2]
      average_forecast_value <- mean(lower_bound_forecast)
    }
    
    percentage_increase <- ((average_forecast_value - last_close) / last_close)*100*0.5
  }
  
  # OUTPUT
  cat(round(percentage_increase, 2), "%\n")
  cat("   General Trend for", ticker, " is:", trend," \n")
  
  
  
}

