
###EURO ZONE###
#please install packages as needed
#install.packages("forecast")  
library(forecast)             
library(tseries)
library(astsa)
library(rugarch)

#we pull up the data 
#this data is from Jan 4, 1999 to Oct 30, 2026
data <- read.csv("data/DEXUSEU.csv", header = TRUE, na.strings = c("","."))
data$observation_date <- as.Date(data$observation_date)
names(data)[2] <- "eurusd"
data <- na.omit(data)
nrow(data)

#make a graph to show the relationship between euro and usd
par(mfrow=c(1,1))
plot(x=data$observation_date, y=data$eurusd, xlab='Date', ylab='EURO/USD', type="l")

#log the data for interpretability purposes
par(mfrow=c(1,2))
log_data <- log(data$eurusd)

#check acf and pacf if differencing is needed
acf(log_data)
pacf(log_data)

#random walk behavior so it can benefit from differencing potentially
adf.test(log_data)
ndiffs(log_data)

#differenced and logged data
diff_log_data <- diff(log(data$eurusd))*100
diff_dates <- data$observation_date[-1]
adf.test(diff_log_data)

#plot the graphs after the difference and log
par(mfrow=c(1,1))
plot(x=diff_dates, y=diff_log_data, xlab='Date', ylab='EURO/USD logged and diff', type='l')

#first i want to build the mean model; cannot build a predictable mean based on daily prices
par(mfrow=c(1,2))
acf(diff_log_data)
pacf(diff_log_data)

#i used aic to see if this is justified at all
AIC(arima(diff_log_data, order = c(0,0,0)))
AIC(arima(diff_log_data, order = c(0,0,1)))

#i see that the volatility from the logged and differenced data clusters
#square the returns and find the acf and pacf
par(mfrow=c(1,2))
acf(diff_log_data^2)
pacf(diff_log_data^2)

#build the garch model from garch(1,1)
eurusd_spec <- ugarchspec(mean.model = list(armaOrder=c(0,0)),
                        variance.model = list(garchOrder=c(1,1)))
eurusd_model <- ugarchfit(data = diff_log_data, spec = eurusd_spec)  
eurusd_model
  
#tells us that alpha is .031765 and beta is .964977
#time for a diagnostic check
#first i check the acf and pacf of the residuals of daily returns that i was not able to capture
#i need to standardize the residuals to measure the jumps relative to what the model expected
residuals(eurusd_model)
x <- as.numeric(residuals(eurusd_model, standardize=TRUE))
par(mfrow=c(1,2))
acf(x)
pacf(x)
par(mfrow=c(1,1))
plot(residuals(eurusd_model,standardize=TRUE),x=diff_dates,type='h',xlab='Date',ylab='Standardized Residuals')

#next i check the acf and pacf of the residuals of daily returns squared
par(mfrow=c(1,2))
acf(x^2)
pacf(x^2)

#use a ljung box test just to be sure
Box.test(x^2, lag = 20, type = "Ljung-Box")


#forecasting
#first i want to hold out the last 1500 days
par(mfrow=c(1,1))
n_test <- 1500
eurusd_fit_test <- ugarchfit(spec = eurusd_spec, data = diff_log_data, out.sample = n_test)

#forecast makes a prediction one day at a time
eurusd_roll <- ugarchforecast(eurusd_fit_test, n.ahead = 1, n.roll = n_test - 1)

#make a list of the predicted and actual variance 
sigma_fore <- as.numeric(sigma(eurusd_roll))
actual_ret <- tail(diff_log_data, n_test)
realized_var <- actual_ret^2

#build the benchmark naive variance
train_ret <- head(diff_log_data, length(diff_log_data) - n_test)
const_var <- var(train_ret)

#examine the residual squared of the actual vs predicted variance
#examine the residual squared of the actual vs benchmark variance
mean((realized_var - sigma_fore^2)^2)
mean((realized_var - const_var)^2)

plot(abs(actual_ret), type = 'h', col = 'grey', ylab = 'daily move size (%)')
lines(sigma_fore, col = 'red')
abline(h = sqrt(const_var), col = 'blue')
