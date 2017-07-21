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

The data collected from Twitter and Facebook contains a lot of noise and needed to be processed before we can move into models development. 

### A. Common data preprocessing steps

After joining datasets from Twitter and Facebook, we decided to construct a common data preprocessing framework for both sentiment analysis and topic monitoring. The combined dataset would go through a series of shared steps: missing values and duplicates would be deleted; then URLs and numbers are removed; next converted text to ASCII and time-dates are parsed.

### B. Acronyms/ Abbreviation Translation

In order to catch the meaning of each text in our data, we need to use acronym dictionaries to detect and convert special terms into original forms of words or sentences. At the moment, we are still developing our own decoder for emoticons and abbreviations at the moment.

### C. Language Detection

Though nearly 90 % of the data we collected are in English, the remaining texts are written in other languages. Concerned text analysis to be consistent, we directly dropped the data, of which the messages are not in English. Before discarding, we need to detect the languages of the text. In Python, we used the package “langdetect”, ported from Google's language-detection machine which achieved 80% accuracy. After trying to implement several packages, we decided to integrate “franc” package into our preprocessing pipeline because it uses ISO692_2 which includes more languages, has higher accuracy in compare with “textcat” and do not have limited usages as compared to API.

### D. Tokenization

We utilized text mining package “tm" from R and “wordpunct_tokenize” from Natural Language Toolkit(NLTK) in
Python to extract bags of clean terms from the raw texts. 

### E. Stop-words removal

The general strategy for determining a stop list is to sort the terms by collection frequency (the total number of times each term appears in the document collection), and then to take the most frequent terms out. Here, we continued to use R’s “tm" package and “stopwords” from “NLTK” in Python. With the packages, there already exists the stop word dictionaries in different languages

### F. Part of Speech (POS)

In Python, we use the tool “pos_tag” from “NLTK” while in R, we mainly used the same text mining “tm" package. 

### G. Lemmatization

We used “WordNetLemmatizer” from “NLTK” for Python, which does full morphological analysis to accurately identify the lemma for each word. In R, we use a the tool called “textstem” built in the package textstem. 

### H. Document-Term-Matrix

A document-term matrix (DTM) or term-document matrix is a mathematical matrix that describes the frequency of terms that occur in a collection of documents. We tried to build the matrix using predefined functions in R and Python packages, but after found out that our training dataset was too large for R to grow the matrix, we are currently using texts vectorization which is creating a map from words or n-grams to a vector space to reduce memory usage. The package in R we are testing is “text2vec” for vectorization before constructing DTM and the official “tm” text mining package.

## Sentiment Analysis

### A. Methodology

For the first two months of this project, we focused on the three approaches: dictionary-based (lexicon-based approach), probabilistic classifier (naive-bayes) and linear classifier (binomial regression).

#### a. Lexicon-based

One way to analyze the sentiment of a text is to consider the text as a combination of its individual words and the sentiment content of the whole text as the sum of the sentiment content of the individual words. It is a simple method but also mostly used in many sentiment analysis projects. **Dictionary-based approach** - We began by getting a list of relevant packages in R and Python, then picked those with highest usages and applied them to our dataset. The R packages were “**syuzhet**”, “**sentimentR**” and the Python package was “**Textblob**”. The lexicons we were applying were: _Bing Liu lexicon, NRC lexicon, AFINN and Jocker’s dictionary_.

#### b. Machine Learning based

Since sentiments can be placed on a scale from positive to negative, we believe this problem is then developed into a classification task in the machine learning domain. We were able to obtain a Twitter dataset from the Standford Following this approach, we have developed two models using Naive Bayes (probabilistic classifier) and one using Binomial regression (linear classifier). Furthermore, we obtained a set of more than **1.600.000 tweets** (_Sentiment140_) which is provided by Stanford NLP. The training data was automatically created, as opposed to having humans manual annotate tweets and it contains sentiments scores from the Maximum Entropy classifier and have data related to multiple domains. After trained the models, we applied them on our current available dataset and visualized the temporary results.

### B. Results

Due to the facts that each member tested out different models on different partitions of the available collected datasets, it was concluded that we should have a consolidated test dataset with predefined sentiment labels to make reliable comparisons. As can be seen from the graph above, using binomial regression, most of the tweets mentioned “humira” are neutral and the number of “negative” tweets is higher than “positive”. However, after digging into the results by extracting top negatives and positives, we realized that the negative tweets might not target the drug but rather the diseases or the painfulness. We would continue to analyze and develop a countermeasure against this issue in the near future.

### C. Challenges & Next Steps

The current challenges in sentiment analysis can be summarized into three topics: data quality, parameters tuning and methods evaluation. 

+ Even though the datasets are preprocessed, we still need to treat Facebook and Twitter data differently due to their uniqueness. For Facebook, because of the hierarchy of posts - comments - reactions: while a post usually raises a topic and contains a certain valence, the comments under sometimes possess multiple opinions cover different subjects and the reactions are also hard to monitor due to this diversity. Twitter, on the other hand, is limited to 140 characters and tweets are usually “hashtag-ed” with keywords; thus user’ opinions are clearly encircled only those “topics”. 

+ The next challenges are parameters tuning and methods evaluation. Since each methods adapt different ways to classify sentiments in texts, they require different approaches to achieve better results. We believe that this optimization step is the next step after we obtain the evaluations between all available methods. 

+ Last but not least, after finish tuning, we will develop common procedures to evaluate all the existing methods. A shared test dataset is crucial in this part; thus, we are going to develop a manual sentiment label test dataset as our next step. 

For the next phase, after finish evaluating existing techniques and achieve certain good results, especially for Twitter dataset; we would like to invest in dealing with some of the current problems in sentiment analysis such as: building a classifier for subjective vs objective tweets, handling negation and comparison; determine context switch; building an accurate parsers for tweets; sarcasm detection and internalization.

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
