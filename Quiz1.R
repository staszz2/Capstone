library(reshape2)
library(ggplot2)

dstwitter <- c("C:\\temp\\en_US.twitter.txt","Twitter")
dsnews    <- c("C:\\temp\\en_US.news.txt", "News")
dsblogs   <- c("C:\\temp\\en_US.blogs.txt","Blogs")
all <- rbind(dstwitter,dsnews,dsblogs)

filestats <- data.frame(all,stringsAsFactors=FALSE)
names(filestats) <- c("path","name")

for(dsname in row.names(filestats))
{
  cat("Reading dataset ", dsname, " from ", as.character(filestats[dsname,1]), "\n", sep=" ")
  con <- file(as.character(filestats[dsname,1]), "r", blocking = FALSE)
  
  #assign(dsname, readLines(con,skipNul = TRUE, n=1000, encoding = "UTF-8"))
  assign(dsname, readLines(con,skipNul = TRUE, encoding = "UTF-8"))
  
  close(con)
  cat("---" , as.character(filestats[dsname,2]), " dataset stats---", "\n", sep=" ")
  

  filestats[dsname,3] <- length(get(dsname))
  names(filestats)[3] <- "lines"
  cat("Lines loaded: " , filestats[dsname,3], "\n", sep=" ")
  
  filestats[dsname,4] <- max(sapply(get(dsname),nchar))
  names(filestats)[4] <- "max"
  cat("Maximum line length", filestats[dsname,4], "\n", sep=" ")
  
  filestats[dsname,5] <- mean(sapply(get(dsname),nchar))
  names(filestats)[5] <- "mean"
  cat("Average line length", filestats[dsname,5], "\n", sep=" ")
  

  filestats[dsname,6] <- median(sapply(get(dsname),nchar))
  names(filestats)[6] <- "median"
  cat("Median line length", filestats[dsname,6], "\n", sep=" ")
  
  filestats[dsname,7] <- sum(sapply(gregexpr("\\W+", get(dsname)), length) + 1)
  names(filestats)[7] <- "words"
  cat("Number of words", filestats[dsname,7], "\n", sep=" ")
  
  print(object.size(get(dsname)), units='auto')
  
  cat("\n\n")
}

dsall <- c(dstwitter, dsnews, dsblogs)

temp <- melt(filestats, id.vars="name")
#ggplot(filestats, aes(x = factor(name), y = lines)) + geom_bar(stat = "identity")
#ggplot(d[4:18,], aes(name,value)) + geom_point() + stat_smooth() + facet_wrap(~variable)
#ggplot(d[4:18,], aes(x=name,y = value,fill=factor(variable))) +geom_bar(stat = "identity",position="dodge")
ggplot(temp[4:18,], aes(x=name,y = value)) +geom_bar(stat = "identity",position="dodge") + facet_wrap(~variable)

if(FALSE) {
  numLove <- length(grep("love",dstwitter))
  numHate <- length(grep("hate",dstwitter))
  loveHate <- numLove/numHate
  print(loveHate)
  
  dstwitter[grep("biostats",dstwitter)]
  
  dstwitter[grep("A computer once beat me at chess, but it was no match for me at kickboxing",dstwitter)]
}