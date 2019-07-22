library(tm)
library(tidyr)
library(dplyr)
library(SnowballC)
library(stringi)
library(filehash)
library(RWeka)
library(RWekajars)
library(NLP)
library(rJava)
library(wordcloud)
library(RColorBrewer)
library(ggplot2)
library(gridExtra)
library(knitr)

##loading in files and main data 
mainFile <- "C:/Users/Saifeel/Desktop/Data Science/final/en_US"
mainBlog <- "C:/Users/Saifeel/Desktop/Data Science/final/en_US/en_US.blogs.txt"
mainTwitter <- "C:/Users/Saifeel/Desktop/Data Science/final/en_US/en_US.twitter.txt"
mainNews <- "C:/Users/Saifeel/Desktop/Data Science/final/en_US/en_US.news.txt"

##reading in lines from data
con1 <- file(mainBlog, open = "rb")
blogs <- readLines(con1, encoding = "UTF-8", skipNul = TRUE)
close(con1)
con2 <- file(mainTwitter, open = "rb")
twitter <- readLines(con2, encoding = "UTF-8", skipNul = TRUE)
close(con2)
con3 <- file(mainNews, open = "rb")
news <- readLines(con3, encoding = "UTF-8", skipNul = TRUE)
close(con3)

##basic exploratory analysis of files
#size
blogSize <- file.info(mainBlog)$size / 1024^2
twitSize <- file.info(mainTwitter)$size / 1024^2
newSize <- file.info(mainNews)$size  / 1024^2
#length
blogLen <- length(blogs)
twitLen <- length(twitter)
newsLen <- length(news)
#words
blogWC <- sum(sapply(gregexpr("\\S+", blogs), length))
twitWC <- sum(sapply(gregexpr("\\S+", twitter), length))
newsWC <- sum(sapply(gregexpr("\\S+", news), length))
#longest lines
blogMax <- max(nchar(blogs))
twitMax <- max(nchar(twitter))
newsMax <- max(nchar(news))

##create DF with all info compiled 
summaryDF <- data.frame(fileName = c("Blogs", "Twitter", "News"),
                        fileSizeMB = c(blogSize, twitSize, newSize),
                        LineCount = c(blogLen, twitLen, newsLen),
                        maxLine = c(blogMax, twitMax, newsMax),
                        WordCount = c(blogWC, twitWC, newsWC))
saveRDS(summaryDF, file = "./milestone/summaryDF.Rda")

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


gSize <- ggplot(data = summaryDF, aes(x = summaryDF$fileName, y = summaryDF$fileSizeMB)) + 
  geom_bar(stat = "identity", fill = c("darkorchid4", "seagreen4", "dodgerblue2")) + xlab("Text File Source") + ylab("File Size (MB)")
gLC <- ggplot(data = summaryDF, aes(x = summaryDF$fileName, y = summaryDF$LineCount)) + 
  geom_bar(stat = "identity", fill = c("darkorchid4", "seagreen4", "dodgerblue2")) + xlab("Text File Source") + ylab("Total number of lines")
gML <- ggplot(data = summaryDF, aes(x = summaryDF$fileName, y = summaryDF$maxLine)) + 
  geom_bar(stat = "identity", fill = c("darkorchid4", "seagreen4", "dodgerblue2")) + xlab("Text File Source") + ylab("Length of Longest Line")
gWC <- ggplot(data = summaryDF, aes(x = summaryDF$fileName, y = summaryDF$WordCount)) + 
  geom_bar(stat = "identity", fill = c("darkorchid4", "seagreen4", "dodgerblue2")) + xlab("Text File Source") + ylab("Total Word Count")
gg5 <- multiplot(gSize, gLC, gML, gWC, cols=2) 

saveRDS(gg5, "./milestone/gg5.RDS")


#getting samples from each dataset
      ### INCREASE SAMPLE SIZES BEFORE FINALIZING MODEL ###
set.seed(2323)
sTwit <- twitter[sample(1:length(twitter),5000)]
sNews <- news[sample(1:length(news),5000)]
sBlogs <- blogs[sample(1:length(blogs),5000)]
#sampled main, all three samples 
sMain <- c(sTwit, sNews, sBlogs)
writeLines(sMain, "./milestone/sMain.txt")

####creating corpus and cleaning it###
CorpCon <- file("./milestone/sMain.txt")
mainCorp <- readLines(CorpCon)
mainCorp <- Corpus(VectorSource(mainCorp))
close(CorpCon)


#cleaning corpus to lowercase, ident words, remove punct, nums, urls, stopwords

removeURL <- function(x) gsub("http[[:alnum:]]*", "", x) 
removeApo <- function(x) gsub("'", "", x)

##mainCorp <- tm_map(v, removeApo, "'")

cleaner <- function (s) {
  s <- tm_map(s, content_transformer(function(x) iconv(x, to="UTF-8", sub="byte")))
  s <- tm_map(s, content_transformer(tolower))
  s <- tm_map(s, content_transformer(removeApo))   ######################################################## remove or fix don't -> don t 
  s <- tm_map(s, removePunctuation)
  s <- tm_map(s, removeNumbers)
  s <- tm_map(s, content_transformer(removeURL))
  s <- tm_map(s, stripWhitespace)
  s <- tm_map(s, removeWords, stopwords("en"))
  s <- tm_map(s, stemDocument)
  s <- tm_map(s, stripWhitespace)
  s
}

cMain1 <- cleaner(mainCorp)

#saving cleaned corpus

saveRDS(cMain1, file = "./milestone/finalCorp.RDS")

FCorp <- readRDS("./milestone/finalCorp.RDS")
## creating dataframe of our final corpus ##
FCorpDF <- data.frame(text = sapply(FCorp,identity), 
                      stringsAsFactors = FALSE)

##wordCloud 
TDM <- TermDocumentMatrix(FCorp)
wordCloud <- as.matrix(TDM)
wc <- sort(rowSums(wordCloud), decreasing = TRUE)
wcDF <- data.frame(word = names(wc), freq = wc)
WC <- wordcloud(wcDF$word, wcDF$freq, c(5,.3), 50, 
                random.order = FALSE, colors = brewer.pal(8, "Dark2"))

#creating N-gram model for n=1,2,3

ngramToken <- function(cc, n){
  NGT <- NGramTokenizer(cc, Weka_control(min = n, max= n,
                                         delimiters = " .,;:'()\"?!\\r\\n\\t\\W"))
  NGT <-  data.frame(table(NGT))
  colnames(NGT) <- c("Term", "Freq")
  NGT <- NGT[order(-NGT$Freq), ]
  NGT
}

##creating n-gram dataframes and saving 
#n=1
uniGram <- ngramToken(FCorpDF, 1)
saveRDS(uniGram, "./milestone/uniGram.RDS")
#n=2
biGram <- ngramToken(FCorpDF, 2)
saveRDS(biGram, "./milestone/biGram.RDS")
#n=3
triGram <- ngramToken(FCorpDF, 3) 
saveRDS(triGram, "./milestone/triGram.RDS")
#n=4
quadGram <- ngramToken(FCorpDF, 4)
saveRDS(quadGram,"./milestone/quadGram.RDS")

#plotting n-grams 

uniPlot <- ggplot(data = uniGram[1:10,], aes(x=Term, y = Freq)) 
uniPlot <- uniPlot + geom_bar(stat="identity", fill = "seagreen") + coord_flip() +
  ggtitle("Frequency Words for Unigram") 

biPlot <- ggplot(data = biGram[1:10,], aes(x=Term, y = Freq)) 
biPlot <- biPlot + geom_bar(stat="identity", fill = "deepskyblue4") + coord_flip() +
  ggtitle("Frequency Words for Bigram") 

triPlot <- ggplot(data = triGram[1:10,], aes(x=Term, y = Freq)) 
triPlot <- triPlot + geom_bar(stat="identity", fill = "red") + coord_flip() +
  ggtitle("Frequency Words for Trigram") 

quadPlot <- ggplot(data = quadGram[1:10,], aes(x=Term, y = Freq)) 
quadPlot <- quadPlot + geom_bar(stat="identity", fill = "firebrick3") + coord_flip() +
  ggtitle("Frequency Words for Quadgram") 

##ggsave("gram.pdf", arrangeGrob(uniPlot, biPlot, triPlot, quadPlot))

x <- grid.arrange(uniPlot, biPlot, triPlot, quadPlot)


## Prediction model Building ##

# break down n-gram model DF #

# uniGram DF is good already #

biGramDF <- biGram %>% separate(Term, c("word1", "word2"), sep = " ")
triGramDF <- triGram %>% separate(Term, c("word1", "word2", "word3"), sep = " ")
quadGramDF <- quadGram %>% separate(Term, c("word1", "word2", "word3", "word4"), sep = " ")

#create DF with all n-grams with Freq > 10/20/30/50/all?


## see untitled1* for structure of prediction function  



