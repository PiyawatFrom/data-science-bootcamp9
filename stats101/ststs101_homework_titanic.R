library(titanic)
library(tidyverse)
library(glue)

titanic_df <- as_tibble(titanic_train)

str(titanic_df)

nrow(titanic_df) # Original : 891, After : 714

titanic_df <- na.omit(titanic_df) # Drop all NA row



## change column Dtypes
titanic_df$Sex <- factor(titanic_df$Sex)
titanic_df$Cabin <- factor(titanic_df$Cabin)
titanic_df$Embarked <- factor(titanic_df$Embarked)

titanic_df



## split data
set.seed(42)
n <- nrow(titanic_df)
id <- sample(1:n, size = n*0.7) #  70% Train , 30% test

train_data <- titanic_df[id, ]

test_data <- titanic_df[-id, ]


## Train Model 
logis_model <- glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked,
    data = train_data, family = "binomial")

summary(logis_model)



## Test model
test_data$prob_survived <- predict(logis_model,newdata = test_data , type = "response")

theh <- 0.45 # Theshold

test_data$pred_sur <- if_else(test_data$prob_survived >= theh, 1 , 0)


## Accuracy
conM <- table(test_data$pred_sur, test_data$Survived, dnn = c("Predicted", "Actual"))

acc <- (conM[1,1]+conM[2,2])/sum(conM)
preci <- conM[2,2]/(conM[2,1] + conM[2,2])
rec <- conM[2,2]/(conM[1,2] + conM[2,2])

f1 <- 2*preci*rec/(preci+rec)

conM
glue("Accuracy  : {acc} 
      Precision : {preci} 
      Recall    : {rec} 
      F1        : {f1}" )
