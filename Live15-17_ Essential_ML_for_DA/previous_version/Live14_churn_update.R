## Library
library(tidyverse)
library(caret)
library(visdat)
library(ROSE)
library(mlbench)
library(MLmetrics)


## read data
churn_df <- read_csv("churn.csv")


## review data
glimpse(churn_df)


## no missing value
mean(complete.cases(churn_df)) # if 1 then no NA


## 1. split data
set.seed(47)
n <- nrow(churn_df)
id <- sample(1:n, size = 0.8*n)

train_df <- churn_df[id, ]
test_df <- churn_df[-id, ]



## EDA

colnames(train_df)

## numeric cols

mean_col <- train_df |>
    group_by(churn) |>
    summarise(across(where(is.numeric), mean))

X <- t(mean_col)[2:16,]
X <- data.frame(X)
X["diff"] <- as.numeric(X[,1]) - as.numeric(X[,2])

X <- X |> filter(abs(diff) > 2 )

rownames(X)

## cat cols

train_df |>
    group_by(churn) |>
    count(internationalplan)


train_df |>
    group_by(churn) |>
    count(voicemailplan)




## min max scaling [0,1]
transformer <- preProcess(train_df,
                          method = c("center","scale"))

train_df <- predict(transformer, train_df)
test_df <- predict(transformer, test_df)



## Under and Over sampling

# before
train_df |>
    count(churn)
nrow(train_df)

n_yes <- nrow(train_df |> filter(churn == "Yes"))
n_no <- nrow(train_df |> filter(churn == "No"))
n_dif <- n_no - n_yes

n_new <- nrow(train_df) + n_dif

train_df <- ovun.sample(churn ~. ,
                        data = train_df,
                        method = "both",
                        p = 0.5,
                        seed = 222,
                        N = n_new )$data

train_df <- as_tibble(train_df)

# After
train_df |>
    count(churn)
nrow(train_df)



## select feature

train_df <- train_df |>
    select(churn, internationalplan , voicemailplan, accountlength ,
           numbervmailmessages, totaldayminutes   , totaldaycharge , 
           totaleveminutes   ,  totalnightminutes  )

test_df <- test_df |>
    select(churn, internationalplan , voicemailplan, accountlength ,
           numbervmailmessages, totaldayminutes   , totaldaycharge , 
           totaleveminutes   ,  totalnightminutes  )



## 2. train model

## Logistic reg
set.seed(42)
logis_ctrl <- trainControl(method = "cv",
                     number = 5,
                     summaryFunction = prSummary, # pr = precision + recall
                     classProbs = TRUE)

logis_model <- train(churn ~. ,
                     data = train_df,
                     method = "glm",
                     metric = "F",
                     trControl = logis_ctrl)


## knn model 
set.seed(42)

k_grid <- data.frame(k = c(3,5,7,21,33,51,61,75)) # k in knn

knn_ctrl <- trainControl(method = "cv",
                     number = 5,
                     summaryFunction = prSummary, # pr = precision + recall
                     classProbs = TRUE)


knn_model <- train(churn ~. ,
                   data = train_df,
                   method = "knn",
                   metric = "F",
                   trControl = knn_ctrl,
                   tuneGrid = k_grid)



## 3. Score
p_logReg <- predict(logis_model, newdata = test_df)

p_knn <- predict(knn_model, newdata = test_df)



## 4. evaluate

## change to factor
test_df$churn <- as.factor(test_df$churn)

## confusion matrix logistic reg
confusionMatrix(p_logReg , test_df$churn ,
                positive = "Yes" ,     # what class you interest
                mode = "prec_recall")  # for look precision , recall,  f1 


## confusion matrix knn
confusionMatrix(p_knn , test_df$churn ,
                positive = "Yes" ,     # what class you interest
                mode = "prec_recall")  # for look precision , recall,  f1 




