# Euro/Dollar Analysis

**Data:** U.S. Dollars to Euro Spot Exchange Rate via FRED (DEXUSEU), daily, Jan 4, 1999 to Oct 30, 2026 (6,979 observations omitting blanks)

## Are there any predictable patterns in EURO/USD and how well can GARCH model forecast volatility?

- First plot the data
- Look at the data and determine from eye test that it is not stationary
    - Mean is not constant
    - Variance is not constant
- I log the data for interpretability purposes
    - Log returns are roughly percentage changes
- I check the ACF and PACF to see if any differencing is required
    - ACF is stubborn and won’t go down 
    - PACF only has one spike at lag 1 and goes down abruptly
    - This trend is consistent with a random walk
- Use the ADF test to check for a unit root
    - The p value was .63 so we fail to reject the null hypothesis of a unit root
    - ndiffs says to difference once
- I difference the data once as recommended and the mean is constant and around 0
    - The variance is still not constant
- First, I want to build up the mean model and see if there’s anything predictable about the mean
    - I use ACF and PACF to see if there’s a potential ARMA model to use
    - ACF has no spikes beyond lag 0 and PACF has no spikes
    - I cannot build a predictable mean model based on daily returns
    - AIC test for ARMA(0,0) and MA(1) justifies my reasoning
       - AIC ARMA(0,0): 12049.32
       - AIC MA(1): 12050.43
    - Constant mean of 0 will suffice to model the mean
- Next, I want to build up the variance model
    - I see that the volatility clusters in late 2000s and early 2010s
    - I squared returns to see if GARCH is a good fit
         - I checked the ACF and PACF of the squared returns to check if the size of the daily moves correlate over time
         - The returns of the logged and differenced data are uncorrelated but admit a higher order dependence structure
- I can see from the ACF and PACF that the memory of the correlation is quite long so better to use a GARCH rather than an ARCH to model volatility
    - In ARCH, the current variance would simply be a constant and a percent of the previous day’s squared returns 
    - In GARCH, it would add the previous day’s variance into the ARCH model 
- I decide to use GARCH(1,1) as it is parsimonious and capable with just 3 parameters
    - m is past squared returns ($\alpha$)
    - s is past variance ($\beta$)
    - I used ugarchspec and ugarchfit to create and fit the final model
- $\alpha$ + $\beta$ = .997 which means that volatility is highly persistent

**Final GARCH model:**  

$$r_t = \varepsilon_t = \sigma_t z_t$$

$$\sigma_t^2 = 0.001093 + 0.031765\\varepsilon_{t-1}^2 + 0.964977\\sigma_{t-1}^2$$

## Model diagnostics and forecasting
- I run a few diagnostics to make sure that the model is sound
     - I start by standardizing the data of the residuals to ensure that the measurements are relative to what the model was expecting
     - First, I check the ACF and PACF of the residuals of daily returns to see if there were leftover patterns in mean
     - Next, I check the ACF and PACF of the residuals of daily returns squared to see if there were leftover patterns in variance
     - Across both diagnostics, the resulting spikes were insignificant
- I tested the standardized residuals of daily returns squared with Ljung Box to see if there was any leftover volatility clustering
    - P value of .781 so null hypothesis cannot be rejected (no significant evidence of leftover volatility clustering)
- Lastly, I used a forecast to see how well my GARCH model would predict the volatility of last 1,500 days
     - I use a out of sample, rolling forecast to see how well my GARCH model can predict the daily price variance of the last 1,500 days since the data was pulled
     - I use a benchmark naive prediction as a comparison
          - GARCH(1,1) MSE: 0.1531671
          - Naive prediction MSE: 0.1850385 
     - My results were better than naive prediction and reduced forecast error by 17%
