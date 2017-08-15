setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source("../../scripts/h2o-r-test-setup.R")
library(caret)
library(dplyr)
library(text2vec)
if ("slam" %in% rownames(installed.packages()))
library(slam)
if ("data.table" %in% rownames(installed.packages()))
library(data.table)

# In PUBDEV-4620

check.as.h2o<- function() {
  h2o.removeAll()
  browser()
  dataframeOut1 <- data_frame(output = c('win','lose','win','lose','win','win','win','win','win','lose',
                                         'lose','lose','lose','win','win','win','lose','win','lose','lose'),
                              id = c(1:20),
                              text = c("this is a this", 
                                       "this is another",
                                       'hello',
                                       'what???',
                                       "Wendy Wong", 
                                       "is great", 
                                       "intelligence", 
                                       "strong and healthy",
                                       "and positive", 
                                       "and fuck the world",
                                       "for thinking otherwise",
                                       "now that I have", 
                                       "to think ", 
                                       "of another", 
                                       "six sentences",
                                       "what a chore!", 
                                       "when would I be rich",
                                       "next year?", 
                                       "no more ", 
                                       "than three years"),
                              value = c(200,400,120,300,320,110,430,903,703,390,123, 300, 129, 213, 432, 135, 675, 290, 182, 300))
  
  
  dataframeOut4 <- data_frame(id = c(1:20),
  text = c("this is a this", 
           "this is another",
           'hello',
           'what???',
           "Wendy Wong", 
           "is great", 
           "intelligence", 
           "strong and healthy",
           "and positive", 
           "and fuck the world",
           "for thinking otherwise",
           "now that I have", 
           "to think ", 
           "of another", 
           "six sentences",
           "what a chore!", 
           "when would I be rich",
           "next year?", 
           "no more ", 
           "than three years"),
  value = c(200,400,120,300,320,110,430,903,703,390,123, 300, 129, 213, 432, 135, 675, 290, 182, 300),
  output = c('win','lose','win','lose','win','win','win','win','win','lose',
             'lose','lose','lose','win','win','win','lose','win','lose','lose'))
  
  dataframeOut2 <- data_frame(id = c(1:20),
                           output = c('win','lose','win','lose','win','win','win','win','win','lose',
                                      'lose','lose','lose','win','win','win','lose','win','lose','lose'),
                          text = c("this is a this", 
                                   "this is another",
                                   'hello',
                                   'what???',
                                   "Wendy Wong", 
                                   "is great", 
                                   "intelligence", 
                                   "strong and healthy",
                                   "and positive", 
                                   "and fuck the world",
                                   "for thinking otherwise",
                                   "now that I have", 
                                   "to think ", 
                                   "of another", 
                                   "six sentences",
                                   "what a chore!", 
                                   "when would I be rich",
                                   "next year?", 
                                   "no more ", 
                                   "than three years"),
                          value = c(200,400,120,300,320,110,430,903,703,390,123, 300, 129, 213, 432, 135, 675, 290, 182, 300))
  dataframeOut3 <- data_frame(id = c(1:20),
                              text = c("this is a this", 
                                       "this is another",
                                       'hello',
                                       'what???',
                                       "Wendy Wong", 
                                       "is great", 
                                       "intelligence", 
                                       "strong and healthy",
                                       "and positive", 
                                       "and fuck the world",
                                       "for thinking otherwise",
                                       "now that I have", 
                                       "to think ", 
                                       "of another", 
                                       "six sentences",
                                       "what a chore!", 
                                       "when would I be rich",
                                       "next year?", 
                                       "no more ", 
                                       "than three years"),
                              output = c('win','lose','win','lose','win','win','win','win','win','lose',
                                         'lose','lose','lose','win','win','win','lose','win','lose','lose'),
                              value = c(200,400,120,300,320,110,430,903,703,390,123, 300, 129, 213, 432, 135, 675, 290, 182, 300))
  
  train1 <- prepareFrame(dataframeOut1)
  train2 <- prepareFrame(dataframeOut2)
  train3 <- prepareFrame(dataframeOut3)
  train4 <- prepareFrame(dataframeOut4)


  # Train any H2O model (e.g GBM)
  mymode1 <- runModel(train1)
  summary(mymodel1)
  
  mymodel2 <- runModel(train2)
  summary(mymodel2)
  
  mymode3 <- runModel(train3)
  summary(mymodel3)

  mymodel4 <- runModel(train4)
  summary(mymodel4)
}

runModel<-function(trainFrame) {
  return(h2o.gbm(y="y", training_frame=trainFrame, distribution='bernoulli', seed=1))
}
prepareFrame<-function(dataframe) {
  prep_fun = tolower
  tok_fun = word_tokenizer
  
  #create the tokens
  train_tokens = dataframe$text %>% prep_fun %>% tok_fun
  
  it_train = itoken(train_tokens)
  vocab = create_vocabulary(it_train)
  vectorizer = vocab_vectorizer(vocab)
  dtm_train = create_dtm(it_train, vectorizer)
  
  train <- as.h2o(dtm_train)
  train$y <- as.h2o(dataframe$output)
  
  return(train)
}
# compare_frames <- function(f1, f2, number2Comp) {
#   expect_equal(ncol(f1), ncol(f2))
#   expect_equal(nrow(f1), nrow(f2))
#
#   col_ind <- sample(c(1:ncol(f1)), min(number2Comp, ncol(f1)))
#   row_ind <- sample(c(1:nrow(f1)), min(number2Comp, nrow(f1)))
#   all_index = paste(c(1:number2Comp), row_ind, col_ind)
#
#   for (index in c(1:number2Comp)) {
#       indices = strsplit(all_index[index], " ")
#       rowInd = as.numeric(indices[[1]][2])
#       colInd = as.numeric(indices[[1]][3])
#       expect_equal(f1[rowInd, colInd], f2[rowInd, colInd])
#   }
# }

doTest("PUBDEV-4620: check as.h2o.matrix() with response in different columns", check.as.h2o)