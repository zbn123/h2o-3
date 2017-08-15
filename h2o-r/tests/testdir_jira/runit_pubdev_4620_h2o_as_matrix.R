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
  dataframe <- data_frame(id = c(1,2,3,4,5,6,7,8,9,10,11),
  text = c("this is a this", "this is another",'hello','what???',
           "Wendy Wong", "is great", "intelligence", "strong and healthy",
           "and positive", "and fuck the world","for thinking otherwise"),
  value = c(200,400,120,300,320,110,430,903,703,390,123),
  output = c('win', 'lose','win','lose','win','win','win','win','win','lose','lose'))

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

  # Train any H2O model (e.g GBM)
  mymodel <- h2o.gbm(y = "y", training_frame = train,
  distribution = "bernoulli", seed = 1)

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