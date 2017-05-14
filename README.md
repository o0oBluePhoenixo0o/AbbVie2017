# Topic Monitoring in the Pharmaceutical Industry 
Master Team Project at [University of Manhheim](https://www.uni-mannheim.de/1/english/) for M.Sc. Business Informatics and M.Sc. Business Informatics in Cooperation with AbbVie Inc.

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

## Data Preprocessing

## Sentiment Analysis

### Packages

In Sentiment Analysis we evaluated different libraries and packages from R and Python to find the best pre-trained one and also to built our own classifiers based on some packages.

| Package Name                                          | Language | Type                                | 
|-------------------------------------------------------|----------|-------------------------------------|
| [syuzhet](https://github.com/mjockers/syuzhet)        | R        | Lexicon based SA                    |
| [sentimentR](https://github.com/trinker/sentimentr)   | R        | Lexicon based SA                    |
| [sentR](https://github.com/mananshah99/sentR)         | R        | Naive Bayes                         |
| [e1071](https://github.com/cran/e1071)                | R        | Used to built own Naive Bayes Model |
| [glmnet](https://github.com/cran/glmnet)              | R        | Used to built own Regression Model  |
| [textblob](https://github.com/sloria/TextBlob)        | Python   | Lexicon based SA                    |
| [vader](http://www.nltk.org/api/nltk.sentiment.html)  | Python   | Lexicon based SA                    |



## Topic and Trend Detection

## Combining SA and TD
