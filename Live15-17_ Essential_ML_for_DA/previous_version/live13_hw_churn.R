## Library

library(tidyverse)
library(caret)
library(visdat)
library(ROSE)


## read data

churn_data <- read_csv("churn.csv")


## prepare data

glimpse(churn_data) # preview data
summary(churn_data) # show simple stats 
vis_miss(churn_data) # see NA in picture

colnames(churn_data) # col name


## 1. split data

train_test_split <- function(data, size = 0.8){
    
    # Random row Id
    set.seed(42)
    n <- nrow(data)
    train_id <- sample(1:n, size*n) 
    
    # Filter to make train and test
    train_df <- data[train_id, ] 
    test_df <- data[-train_id, ]
    
    return( list(train_df, test_df) )
}

prep_df <- train_test_split(churn_data)

prep_df[[1]]  # train data
prep_df[[2]]  # test data


## 2. train model with glm model

# count target 

prep_df[[1]] |>
    count(churn) 


# oversampling

train_over <- ovun.sample(churn ~. , data = prep_df[[1]], method = "over")$data

train_over <- as_tibble(train_over)

train_over |>
    count(churn)


# Feature selection

ctrl <- trainControl(method = "cv",
                     number = 10)

model <- train(churn ~ . ,
               data = train_over,
               method = "glm",
               trControl = ctrl)

varImp(model)

# train

model <- train(churn ~ internationalplan + numbercustomerservicecalls +
                   voicemailplan + totalintlcalls + accountlength ,
               data = train_over,
               method = "glm",
               trControl = ctrl)

# model confusion matrix

confusionMatrix(model)


## 3. Score Model

pred_churn <- predict(model, newdata = prep_df[[2]])

actual_churn <- as.factor(prep_df[[2]]$churn)


## 4. evaluate model

confusionMatrix(pred_churn, actual_churn, mode = "everything", positive = "Yes")



