#global beef price modeling and forecasting

#please run install.packages as needed
#install.packages("forecast")  

#set up environment
library(forecast)             
library(tseries)
library(astsa)

#pull up beef data           
data <- read.csv("data/PBEEFUSDQ.csv")
head(data)
data$observation_date
data$observation_date <- as.Date(data$observation_date)

#plot the beef data with no transformations or differencing
plot(x=data$observation_date,y=data$PBEEFUSDQ,"l")
#use boxcox to see what kind of transformation is needed
BoxCox.lambda(data$PBEEFUSDQ)
#log to stabilize and graph the new data
log_beef <- log(data$PBEEFUSDQ)
log_beef
plot(x=data$observation_date, y=log_beef, type="l")

#acf and pacf of log beef prices; also finding the number of differences needed
acf(log_beef)
pacf(log_beef)
ndiffs(log_beef)
#difference to make stationary; graph new data; use adf to see if stationary
diff_dates <- data$observation_date[-1]
diff_data <- diff(log_beef)
plot(x=diff_dates, y=diff_data, type = "l")
adf.test(diff_data)
#acf and pacf of transformed and differenced data
acf(diff_data)
pacf(diff_data)

#use auto.arima to see if there are alternative models
auto.arima(diff_data)

#make the models
AR5_r <- arima(diff_data,order = c(5,0,0),fixed=c(0,0,0,0,NA,0))
ARMA52 <- arima(diff_data,order = c(5,0,2))
MA5_r <- arima(diff_data, order = c(0,0,5), fixed = c(0,0,0,0,NA,0))
ARMA55_r <- arima(diff_data, order = c(5,0,5), fixed = c(0,0,0,0,NA, 0,0,0,0,NA, 0))
AR5_r
ARMA52
MA5_r
ARMA55_r

#check the AIC to see which model works best
AIC(AR5_r)
AIC(ARMA52)
AIC(MA5_r)
AIC(ARMA55_r)

#use sarima to check the diagnostics
sarima(diff_data, p=5, d=0, q=0, fixed=c(0,0,0,0,NA,0), include.mean=FALSE)


#train and forecast data
data_less_15 <- data[1:(nrow(data) - 15),]
experimental_data <- ts(data[,2], start=1990, freq=4)
data_less_15
train_data <- ts(data_less_15[,2],start=1990,freq=4)
train_data
par(mfrow=c(1,1))

nobs <- length(train_data)
AR5_diff <- arima(log(train_data), order = c(5, 1, 0), xreg=1:nobs, fixed=c(0,0,0,0,NA,NA), include.mean = FALSE)
AR5_fore <- predict(AR5_diff, 15, newxreg=(nobs+1):(nobs+15))
fore_price <- exp(AR5_fore$pred)
ts.plot(experimental_data, fore_price, col=1:2)

#measure accuracy via RMSE and MAPE
#forecast result
actual <- tail(experimental_data, 15)
sqrt(mean((actual - fore_price)^2))            
mean(abs((actual - fore_price) / actual)) * 100  

#naive result
naive_price <- rep(tail(train_data, 1), 15)
sqrt(mean((actual - naive_price)^2))              
mean(abs((actual - naive_price) / actual)) * 100  

