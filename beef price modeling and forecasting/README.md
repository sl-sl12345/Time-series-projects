# Global Beef Price Modeling and Forecasting

**Data:** IMF global beef price via FRED (PBEEFUSDQ), quarterly, US cents per pound,
Q1 1990 to Q2 2025 (142 observations)

## Question: What patterns appear in quarterly changes in global beef prices, and can they be used to forecast future prices?

## Method
- First plot the data
- Look at the data and determine from eye test that it is not stationary
    - Mean is not constant
    - Variance is not constant
- Use BoxCox to determine if the growing variance over time can be lowered
    - Resulting lambda was -.14 so it was close to 0
        - Logging the data is a good way to lower the variance
- Logging the data subdues the variance just a little but still has an upward trend
- The ACF does not drop to 0 fast enough which suggests it still is not stationary
- I can reduce the stochastic trend by differencing
    - I use ndiffs on R to determine how many times to difference by and it resulted in 1
- The model is visually stationary and I confirm with an ADF test to determine if it is stationary, which it is
- ACF and PACF only has one significant spike at lag 5
    - auto.arima function on R recommends ARMA(5,2)
- I use AIC to determine which model between AR(5) restricted, MA(5) restricted, ARMA(5,5) restricted, and ARMA(5,2) get penalized the least
    - AIC(AR5_r): -375.9539
    - AIC(MA1_r): -374.0754
    - AIC(ARMA55_r): -373.9792
    - AIC(ARMA52): -372.5335
- AR(5) restricted got punished the least; good practice to follow principle of parsimony
- I use the arima function to determine the coefficient of AR(5) restricted 

**Final model:** $(1+.3445B^5)(1-B)\log(X_t) = w_t$

## Model diagnostics and forecasting
- I can look at the diagnostics to see the robustness of my model
    - sarima function can be used to check the residuals
    - I used Ljung-Box statistic to see if there were p values that were statistically significant in my residuals
    - All Ljung-Box p values were above .05
- I used a forecast to check how well the model would predict the last 15 quarters
    - It was able to correctly anticipate the pull down around 2023 but did not get the spike around 2025
    - It shows the limitations of AR since it cannot predict sudden surges
    - Forecast settles into drift as the AR effect slowly fades
- I used the root mean squared error and the mean absolute percentage error to measure how my predictions fared in comparison to naive prediction
    - forecast RMSE and MAPE: 19.11 cents per pound and 6.60%
    - naive RMSE and MAPE: 24.83 cents per pound and 8.72%
- My results were better than naive prediction
