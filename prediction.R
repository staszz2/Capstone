#dplyr for chaining
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(tm)))

gram1  <- readRDS("./grams/onegramwithstopwords.RData", refhook = NULL)
gram1  <- gram1[order(gram1$count),]
gram2a <- readRDS("./grams/bigramwithstopwords.RData", refhook = NULL)
gram2a <- gram2a[order(gram2a$count),]
gram2b <- readRDS("./grams/bigramnostopwords.RData", refhook = NULL)
gram2b <- gram2b[order(gram2b$count),]
gram3a <- readRDS("./grams/trigramnostopwords.RData", refhook = NULL)
gram3a <- gram3a[order(gram3a$count),]
gram3b <- readRDS("./grams/trigramwithstopwords.RData", refhook = NULL)
gram3b <- gram3b[order(gram3b$count),]
gram4  <- readRDS("./grams/fourgramwithstopwords.RData", refhook = NULL)
gram4 <- gram4[order(gram4$count),]

debug <-FALSE 

processInput <- function(text)
{
  #cut off sentence at last period and process just that
  sentences <- unlist(strsplit(text, "[.]"))
  prepped <- sentences[length(sentences)] %>% tolower() %>% removeNumbers() %>% removePunctuation() %>% stripWhitespace() %>% trimws("l")
  prepped
}

predictNext <- function(cleanText) 
{
  wordcount <- length(unlist(strsplit(cleanText, "[ ]")))
  
  if (wordcount == 0)
  {
    return(c("No predictions"))
  }
  
  textLength <- nchar(cleanText)
  lastChar <- substr(cleanText,textLength,textLength)
  
  #if user finished word use bi-tri-fourgrams
  #if user is typing word use onegram
  if(lastChar == " ")
  {
    topChoices <- 5
    splitWords <- unlist(strsplit(cleanText, "[ ]"))
    
    currentPhrase <- paste(splitWords[length(splitWords)], " ", sep="")
    temp2a <-tail(gram2a[grep(paste("^",currentPhrase,sep=""), gram2a$phrase),],topChoices)
    temp2b <-tail(gram2b[grep(paste("^",currentPhrase,sep=""), gram2b$phrase),],topChoices)
    if(debug)
    {
      print("Space zone")
      print("gram2")
      print(temp2a)
      print(temp2b)
    }
    temp2 <- rbind(temp2a,temp2b)
    if(nrow(temp2) > 0) { temp2$gram <- as.double(2) }
    temp3 <- temp2[0,]
    temp4 <- temp2[0,]
    
    if(length(splitWords) >= 2)
    {
      currentPhrase <- paste(splitWords[length(splitWords)-1], splitWords[length(splitWords)], sep=" ")
      temp3a <-tail(gram3a[grep(paste("^",currentPhrase,sep=""), gram3a$phrase),],topChoices)
      temp3b <-tail(gram3b[grep(paste("^",currentPhrase,sep=""), gram3b$phrase),],topChoices)
      if(debug)
      {
        print("gram3")
        print(temp3a)
        print(temp3b)
      }
      temp3 <- rbind(temp3a,temp3b)
      if(nrow(temp3) > 0) { temp3$gram <- as.double(3) }
      
      if(length(splitWords) >= 3)
      {
        incompletePhrase <- paste(splitWords[length(splitWords)-2],splitWords[length(splitWords)-1], splitWords[length(splitWords)], sep=" ")
        temp4 <-tail(gram4[grep(paste("^",incompletePhrase,sep=""), gram4$phrase),],topChoices)
        if(debug)
        {
          print("gram4")
          print(temp4)
        }
        if(nrow(temp4) > 0) { temp4$gram <- as.double(4) }
      } #4
    } #3
    
    
    pred.results <- rbind(temp2,temp3,temp4)
    
    if(nrow(pred.results) > 0) 
    {
      pred.results$word <- getlastWords(pred.results$phrase)
      if(debug)
      {
        print("final prediction table")
        print(pred.results)
      }
      pred.results.sum <- aggregate(cbind(count, gram)~word, data=pred.results, sum, na.rm=TRUE)
      pred.results.sum <- pred.results.sum[order(pred.results.sum$gram),]
      #pred.results.sum
    }
    else
    {
      return(c("No predictions"))
    }
  }
  else
  {
    topChoices <- 5
    
    splitWords <- unlist(strsplit(cleanText, "[ ]"))
    incompleteWord <- splitWords[length(splitWords)]
    temp1 <- tail(gram1[grep(paste("^",incompleteWord,sep=""), gram1$phrase),],topChoices)
    if(debug)
    {
      print("char zone")
      print("gram1")
      print(temp1)
    }
    if(nrow(temp1) > 0) { temp1$gram <- as.double(1) }
    temp2 <- temp1[0,]
    temp3 <- temp1[0,]
    temp4 <- temp1[0,]

    if(length(splitWords) > 1)
    {
      incompletePhrase <- paste(splitWords[length(splitWords)-1], splitWords[length(splitWords)], sep=" ")
      temp2a <-tail(gram2a[grep(paste("^",incompletePhrase,sep=""), gram2a$phrase),],topChoices)
      temp2b <-tail(gram2b[grep(paste("^",incompletePhrase,sep=""), gram2b$phrase),],topChoices)
      if(debug)
      {
        print("gram2")
        print(temp2a)
        print(temp2b)
      }
      temp2 <- rbind(temp2a,temp2b)
      if(nrow(temp2) > 0) { temp2$gram <- as.double(2) }
      
      if(length(splitWords) > 2)
      {
        incompletePhrase <- paste(splitWords[length(splitWords)-2],splitWords[length(splitWords)-1], splitWords[length(splitWords)], sep=" ")
        temp3a <-tail(gram3a[grep(paste("^",incompletePhrase,sep=""), gram3a$phrase),],topChoices)
        temp3b <-tail(gram3b[grep(paste("^",incompletePhrase,sep=""), gram3b$phrase),],topChoices)
        if(debug)
        {
          print("gram3")
          print(temp3a)
          print(temp3b)
        }
        temp3 <- rbind(temp3a,temp3b)
        if(nrow(temp3) > 0) { temp3$gram <- as.double(3) }
        
        if(length(splitWords) > 3)
        {
          incompletePhrase <- paste(splitWords[length(splitWords)-3], splitWords[length(splitWords)-2],splitWords[length(splitWords)-1], splitWords[length(splitWords)], sep=" ")
          temp4 <-tail(gram4[grep(paste("^",incompletePhrase,sep=""), gram4$phrase),],topChoices)
          if(debug)
          {
            print("gram4")
            print(temp4)
          }
          if(nrow(temp4) > 0) { temp4$gram <- as.double(4) }
        } #4
      } #3
    } #2
    
    pred.results <- rbind(temp1,temp2,temp3,temp4)
    
    if(nrow(pred.results) > 0) 
    {
      pred.results$word <- getlastWords(pred.results$phrase)
      if(debug)
      {
        print("final prediction table")
        print(pred.results)
      }
      pred.results.sum <- aggregate(cbind(count, gram)~word, data=pred.results, sum, na.rm=TRUE)
      pred.results.sum <- pred.results.sum[order(pred.results.sum$gram),]
      #pred.results.sum
    }
    else
    {
      return(c("No predictions"))
    }
  } #char
  
  resultVector <- rev(tail(pred.results.sum$word,5))
  resultVector
  
}

getlastWords <- function(column)
{
  lastWords <- vector(mode="character", length=0)
  for (phrase in column)
  {
    splitWords <- unlist(strsplit(phrase, "[ ]"))
    lastWord <- splitWords[length(splitWords)]
    lastWords <- append(lastWords, lastWord)
  }
  return(lastWords)
}
