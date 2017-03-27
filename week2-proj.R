#print(object.size(get("dsnews")), units='auto')
#print(object.size(get("dsblogs")), units='auto')
#print(object.size(get("dstwitter")), units='auto')

library(caret)
library(tm)
library(RWeka)
library(ggplot2)
library(xlsx)
library(wordcloud)
#inTrain <- createDataPartition(y=dstwitter, p=0.9, list=FALSE)
#training <- dstwitter[inTrain, ] 
#testing <- dstwitter[-inTrain, ]

settings <- list()
settings["sourceName"] <- "dsall"
settings["startLine"] <- 1
settings["endLine"] <- 0
settings["lineNumChunk"] <- 7500
settings["redoCurpus"] <- TRUE
settings["minGram"] <- 4
settings["maxGram"] <- 4
settings["removepunctuation"] <- TRUE
settings["removestopwords"] <- FALSE

SomegramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = minLim, max = maxLim))



if(settings[["redoCurpus"]])
{
  print("Reloading corpus")
  objName <- settings[["sourceName"]]
  fileLength <- length(get(objName))
  
  if(settings[["endLine"]] > 0)
    endline <- settings[["endLine"]]
  else
    endline <- length(get(objName))
    
  steps <- ceiling(endline/settings[["lineNumChunk"]])
  
  temp.df <- data.frame(phrase=character(), count=integer())
  
  for (i in 1:steps)
  {
    if(i > steps) break
    
    startLine <- settings[["startLine"]] + settings[["lineNumChunk"]]*(i-1)
    finishLine <- startLine + settings[["lineNumChunk"]]
    
    if(finishLine > fileLength)
    {
      finishLine <- fileLength
      steps <- i
      cat("Finish line changed to ", finishLine, "\n", sep=" ")
    }
    dataChunk <- get(objName)[startLine:finishLine]
    
    print(paste("Performing step ", i ," of ", steps, " start line = ",startLine))
    print("Loaded chunk file size")
    print(object.size(get("dataChunk")), units='auto')

    myCorpus <- VCorpus(VectorSource(dataChunk))
    myCorpus <- tm_map(myCorpus, function(x) iconv(enc2utf8(as.character(x)), sub = "byte")) # remove unreadable characters
    myCorpus <- tm_map(myCorpus, tolower)
    myCorpus <- tm_map(myCorpus, stripWhitespace)
    myCorpus <- tm_map(myCorpus, removeNumbers)
    
    rdsSuffix <- "withstopwords"
    if(settings[["removestopwords"]])
    {
      myCorpus <- tm_map(myCorpus, removeWords, stopwords("english"))
      rdsSuffix <- "nostopwords"
    }
    
    if(settings[["removepunctuation"]])
    {
      myCorpus <- tm_map(myCorpus, removePunctuation)
    }
    
    #myCorpus <- tm_map(myCorpus, stemDocument) 
    Corpus   <- tm_map(myCorpus, PlainTextDocument)

    #inspect(myCorpus[1:2])
    #writeLines(as.character(myCorpus[[2]]))

    minLim <- settings[["minGram"]]
    maxLim <- settings[["maxGram"]]
    
    tdm.somegram = TermDocumentMatrix(Corpus, control = list(tokenize = SomegramTokenizer))
    
    freq <- rowSums(as.matrix(tdm.somegram))
    tdm.somegram.clean = removeSparseTerms(tdm.somegram, 0.999)
    dim(tdm.somegram.clean)
    freq.clean <- rowSums(as.matrix(tdm.somegram.clean))

    freq.clean <- freq.clean[freq.clean>1]
    ordered <- order(freq.clean)
    
    #get only top xx from that data chunk
    topFreq <- freq.clean
    #topFreq <- freq.clean[tail(ordered,500)]
    
    freq.df <- data.frame(phrase = names(topFreq ), count = as.vector(topFreq ))
    temp.df <- rbind(temp.df,freq.df)
  } #end of loop

  
  temp.df.sum <- aggregate(temp.df$count, by=list(phrase=temp.df$phrase), FUN=sum)
  names(temp.df.sum)[names(temp.df.sum)=="x"] <- "count"
  #temp.df.sum[order(temp.df.sum$count),]
  
  rdsPrefix <- switch(settings[["minGram"]], "one", "bi", "tri", "four","five","many") #latinglish mix
  xgramPath <- paste("./",rdsPrefix,"gram", rdsSuffix, ".RData",sep = "")
  saveRDS(temp.df.sum,xgramPath)
} #end of if


tempRDS.df <- readRDS(xgramPath, refhook = NULL)
result.df <- aggregate(count ~ phrase, tempRDS.df, sum)
#wordcloud(words=result.df[,1], freq= result.df[,2],max.words=300, random.order=FALSE,colors=brewer.pal(5, "Dark2"))
#write.xlsx(result.df[with(result.df, order(-count)), ], "C:\\Users\\zveres\\Desktop\\bigrams.xlsx")

graph <- head(result.df[order(-result.df$count),],30)

if(nrow(freq.df) == 0)
{
  stop("No results for given settings")
}

g <- ggplot(graph, aes(reorder(phrase,count), count)) +
  geom_bar(stat = "identity") + coord_flip() +
  xlab("Somegrams") + ylab("Frequency") +
  ggtitle("Most frequent somegrams")
print(g)


if(FALSE)
{
  get(settings[["sourceName"]])[grep("0081",get(settings[["sourceName"]]))]
  #dstwitter[grep("biostats",dstwitter)]
}