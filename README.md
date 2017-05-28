# Topic Monitoring in the Pharmaceutical Industry 
Master Team Project at [University of Manhheim](https://www.uni-mannheim.de/1/english/) for M.Sc. Business Informatics and M.Sc. Data Science in Cooperation with AbbVie Inc.

The project “Topic Monitoring in the Pharmaceutical Industry”,  consists of two goals: to get a better insight into the analysis of public’s opinions, sentiments, evaluations, attitudes, and emotions from social media platforms, especially Facebook and Twitter, towards our client company - AbbVie Inc - and its competitors as well as the whole pharmaceutical industry; and to identify emerging topics in real-time and provide meaningful analytics that synthesize an accurate description of each topic. 

## Content
* [Progamming languages](#programming-languages)
* [Data Collection](#data-collection)
* [Data Preprocessing](#data-preprocessing)
* [Sentiment Analysis](#sentiment-analysis)
* [Topic and Trend Detection](#topic-and-trend-detection)
* [Combining SA and TD](#combining-sa-and-td)


## Programming Languages

In general nearly every programming language can be used for Sentiment Analysis and Topic Detection. But not every language has a mature set of packages and libraries  for text analysis nor a very active community. Therefore we decided to use [R](https://r-project.org) and [Pyhton](https://www.python.org) as our base programming languages. They have a very large community for Natural Language Processing and offer quite a lot packages to analyze texts. In some small secondary tasks we also use some Java based applications.

## Data Collection

The first goal of this project was and still is to built up a sufficient database which can be used to analyze during the project. This was done simultaneously for Facebook and for Twitter. For both data crawling tasks we used the web APIs and the corresporending R packages to crawl the data we needed (Facebook [Rfacebook](https://cran.r-project.org/web/packages/Rfacebook/Rfacebook.pdf) and Twitter [twitteR](https://cran.r-project.org/web/packages/twitteR/twitteR.pdf)). We specifically search for keywords related to the pharmaceutical industry and companies in this area. 

**Keywords for crawling**

| Products   | Companies         | Diseases                      |
|------------|-------------------|-------------------------------|
| adalimumab | abbvie            | ankylosing spondylitis        |
| enbrel     | amgen             | hepatitis c                   |
| humira     | bristol myers     | juvenile idiopathic arthritis |
| ibrutinib  | johnson & johnson | juvenile rheumatoid arthritis |
| trilipix   |                   |                               |

Because of the lack of getting public posts from the FaceBook API we quickly decided to rely more on the Twitter crawl. We also implemented a workflow to crawl the Twitter API on a weekly basis to grow our existing database.

Furthermore we built up a ground truth for Sentiment Analysis and Trend Detection by labeling our self-crawled tweets manually. 

## Data Preprocessing

## Sentiment Analysis

### Packages

In Sentiment Analysis we evaluated different libraries and packages from R and Python to find the best pre-trained one and also to built our own classifiers based on some packages.

| Package Name                                         | Language | Type                                |
|------------------------------------------------------|----------|-------------------------------------|
| [syuzhet](https://github.com/mjockers/syuzhet)       | R        | Lexicon based SA                    |
| [sentimentR](https://github.com/trinker/sentimentr)  | R        | Lexicon based SA                    |
| [sentR](https://github.com/mananshah99/sentR)        | R        | Naive Bayes                         |
| [e1071](https://github.com/cran/e1071)               | R        | Used to built own Naive Bayes Model |
| [glmnet](https://github.com/cran/glmnet)             | R        | Used to built own Regression Model  |
| [textblob](https://github.com/sloria/TextBlob)       | Python   | Lexicon based SA + Naive Bayes      |
| [vader](http://www.nltk.org/api/nltk.sentiment.html) | Python   | Lexicon based SA                    |



## Topic and Trend Detection

## Combining SA and TD
