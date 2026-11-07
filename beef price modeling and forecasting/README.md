# Global Beef Price Modeling and Forecasting

**Data:** IMF global beef price via FRED (PBEEFUSDQ), quarterly, US cents per pound,
Q1 1990 to Q2 2025 (142 observations)

##Method
- First plot the data
- Look at the data and determine from eye test that it is not stationary
    - Mean is not constant
    - Variance is not constant
- Use BoxCox test to determine to see if the variance can be lowered
    - Resulting lambda was -.14 so it was close to 0
        - Logging the data is a good way to lower the variance
- Logging the data subdues the variance just a little but still has an upward trend
- The ACF does not drop to 0 fast enough which suggests it still is not stationary
- I can reduce the stochastic trend by differencing
    - I use ndiff on R to determine how many times to difference by and it resulted in 1
- The model is visually stationary and I confirm with an ADF test to determine if it is stationary, which it is
- ACF only has one significant spike at 5
    - auto.arima function on R recommends ARMA(5,2)
- I use AIC to determine which model between AR(5) restricted and ARIMA(5,1,2) get penalized the least
    - AR(5) restricted got punished the least
- I use the arima function to determine the coefficient of ar5 

**Final model is (1+.3445B^5)(1-B)log(X_t) = w_t** 

#Model diagnostics and forecasting
- I can look at the diagnostics to see the robustness of my model
    - sarima function can be used to check the residuals
    - I used Ljung-Box statistic to see if there were p values that were statistically significant in my residuals 
          - All Ljung-Box p values were above .05
- I used a forecast to check how well the model would predict the last 15 quarters
    - It was able to correctly anticipate the pull down around 2023 but did not get the spike around 2025
    - It shows the limitations of AR since it cannot predict sudden surges
          - Forecast settles into drift as the AR effect slowly fades
- I used the root mean squared error and the mean absolute percentage error to measure how my predictions fared in comparison to naive prediction
    - My results were better than naive prediction
