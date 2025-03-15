import numpy as np
import pandas as pd
import yfinance as yf
from pypfopt.risk_models import CovarianceShrinkage
from pypfopt.black_litterman import BlackLittermanModel
from pypfopt.efficient_frontier import EfficientFrontier
from pypfopt import black_litterman




# Creating a new function to use for Black-Litterman Portfolio Optimization

"""

    Args:
          - tickers_views (dict): Dictionary of stock tickers and expected gains (absolute views).
          - market_caps (dict): Dictionary of stock tickers and market capitalizations.
          - period (str): Period for historical data (default is "10y").
          - risk_aversion_scale (float): Scaling factor for market-implied risk aversion (default is 0.5).

    Returns:
          - dict: Optimized portfolio weights
          - dict: Portfolio performance metrics (Expected Return, Volatility, Sharpe Ratio)

"""




def black_litterman_optimization(tickers_views, mcaps={}, period="10y", risk_aversion_scale=0.5):

    
    # Creating a function that returns the market caps for different companies

    """
         Generates market caps dict from tickers list, only if no market caps are given
        Args:
            t(list): List of tickers, can be found with tickers_views(dict).keys()
        Returns:
            dict: Tickers and market caps
    """

    def get_market_caps(tickers):
        real_market_caps = {}
        for ticker in tickers:
            stock = yf.Ticker(ticker)
            real_market_caps[ticker] = stock.info.get("marketCap", 1e9)  # Default 1 billion if missing
        return real_market_caps



  
    # Extract tickers from the provided dictionary
    assets = list(tickers_views.keys())

    # Download historical data and forward fill data entries with closing prices
    df = yf.download(assets, period=period)['Close'].ffill()

    # Compute log returns and convert to simple returns
    log_ret = np.log(df / df.shift(1)).dropna()
    simple_ret = np.exp(log_ret) - 1

    # Compute covariance matrix
    cov_matrix = np.cov(simple_ret, rowvar=False)
    cov_matrix_df = pd.DataFrame(cov_matrix, index=assets, columns=assets)

    # Compute market capitalization weights, if none given, most recent caps found
    if not mcaps:
        mcaps = get_market_caps(tickers_views.keys())
    mweights = {ticker: cap / sum(mcaps.values()) for ticker, cap in mcaps.items()}

    # Compute Market-implied Prior Returns (pi)
    delta = black_litterman.market_implied_risk_aversion(df) * risk_aversion_scale  # Scale down delta
    pi = black_litterman.market_implied_prior_returns(mweights, delta, cov_matrix_df)

    # Run Black-Litterman Model
    bl = BlackLittermanModel(cov_matrix_df, pi=pi, tickers=assets, absolute_views=tickers_views)
    bl_returns = bl.bl_returns() * 252  # Annualize returns
    bl_cov_matrix = bl.bl_cov()

    # Optimize Portfolio
    ef = EfficientFrontier(bl_returns, bl_cov_matrix)
    weights = ef.max_sharpe()

    # Compute Portfolio Performance
    expected_return, volatility, sharpe_ratio = ef.portfolio_performance(verbose=False)

    # Format Results
    opt_weights = dict(ef.clean_weights())
    exp_ret = float(round(expected_return,2))
    vol = float(round(volatility,4))
    sharpe = float(round(sharpe_ratio,2))

    # Return Results as Dictionaries
    return {
            "Optimized Weights": opt_weights,
            "Portfolio Performance": {
                "Expected Annual Return": exp_ret,
                "Volatility": vol,
                "Sharpe Ratio": sharpe
            }}







# Example using Apple, Nvidia, Visa, Tesla, Intel, Pepsi and TSM

tickers_views = {"AAPL": 0.08, "NVDA": 0.10, "V": 0.07, "TSLA": 0.10, "INTC": 0.11, "PEP": 0.2, "TSM": 0.12} # Views based on opinion



result = black_litterman_optimization(tickers_views, period="10y")
print(result)
