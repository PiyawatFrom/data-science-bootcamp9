library(tidyverse)
library(caret)
library(ROSE)
library(mlbench)
library(MLmetrics)

churn_df <- read_csv("churn.csv")

## no missing value (if 1)
mean(complete.cases(churn_df))

glimpse(churn_df) # see cols and example


## train test split
set.seed(47)
n <- nrow(churn_df)
id <- sample(1:n, size = 0.8*n)

train_df <- churn_df[id, ]
test_df <- churn_df[-id, ]


train_df |>
    count(churn) # No = 3430 , Yes = 570


## under sampling
set.seed(47)
train_no <- train_df |> 
    filter(churn == "No") |>
    sample_n(570)

train_yes <- train_df |>
    filter(churn == "Yes") 

train_df <- bind_rows(train_no, train_yes) # total 1140 row

remove(train_no)
remove(train_yes)


# Function to shuffle the dataframe
shuffle_df <- function(df) {
    # Get the number of rows
    n_rows <- nrow(df)
    
    # Generate a random permutation of row indices
    shuffled_indices <- sample(n_rows)
    
    # Reorder the dataframe using the shuffled indices
    return(df[shuffled_indices, ])
}


train_df <- shuffle_df(train_df)



## normalization z score

transformer <- preProcess(train_df,
                          method = c("center","scale"))

train_df <- predict(transformer, train_df)
test_df <- predict(transformer, test_df)



## select model
set.seed(47)
ctrl <- trainControl(method = "cv",
                     number = 5,
                     summaryFunction = prSummary, # pr = precision + recall
                     classProbs = TRUE)


# generalized linear model
glm_model <- train(churn ~. ,
                     data = train_df,
                     method = "glm",
                     metric = "AUC",
                     trControl = ctrl)


# KNN
knn_model <- train(churn ~. ,
                   data = train_df,
                   method = "knn",
                   metric = "AUC",
                   trControl = ctrl)

# Decision Tree
dt_model <- train(
    churn ~. ,
    data = train_df ,
    method = "rpart",
    metric = "AUC",
    trControl = ctrl
)


## Random Forest
rf_model <- train(
    churn ~ . ,
    data = train_df ,
    method = "rf",
    metric = "AUC",
    trControl = ctrl
)

# Regularization model
glmnet_model <- train(
    churn ~ . ,
    data = train_df ,
    method = "glmnet",
    metric = "AUC",
    trControl = ctrl
)



## score
test_df$churn <- as.factor(test_df$churn)

p_glm <- predict(glm_model, newdata = test_df)
p_knn <- predict(knn_model, newdata = test_df)
p_dt <- predict(dt_model, newdata = test_df)
p_rf <- predict(rf_model, newdata = test_df)
p_glmnet <- predict(glmnet_model, newdata = test_df)


# confusion matrix generalized linear model
confusionMatrix(p_glm , test_df$churn ,
                positive = "Yes" ,     
                mode = "prec_recall")  


# confusion matrix knn
confusionMatrix(p_knn , test_df$churn ,
                positive = "Yes" ,     
                mode = "prec_recall")  

# confusion matrix dicision tree
confusionMatrix(p_dt , test_df$churn ,
                positive = "Yes" ,     
                mode = "prec_recall")  

# confusion matrix Randomforest
confusionMatrix(p_rf , test_df$churn ,
                positive = "Yes" ,     
                mode = "prec_recall")  

# confusion matrix glmnet
confusionMatrix(p_glmnet , test_df$churn ,
                positive = "Yes" ,     
                mode = "prec_recall")  


## select RandanForest Model
## evaluate for RandanForest
set.seed(47)
ctrl2 <- trainControl(method = "repeatedcv",
                     number = 5,
                     repeats = 5,
                     summaryFunction = prSummary, # pr = precision + recall
                     classProbs = TRUE)

# Random Forest
rf_model <- train(
    churn ~ . ,
    data = train_df ,
    method = "rf",
    metric = "AUC",
    tuneGrid = data.frame(mtry = c(2,3,7,9,11,15,17)),
    trControl = ctrl2
)


# confusion matrix RandomForest
confusionMatrix(p_rf , test_df$churn ,
                positive = "Yes" ,     
                mode = "prec_recall") 



## save model
saveRDS(rf_model,"rf_model_for_churn_predict.RDS")
