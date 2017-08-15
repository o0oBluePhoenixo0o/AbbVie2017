/**
 * @constant typeDefinitions
 * @type {String}
 * @description Type definition schema for the GraphQL API. here all types, queries and mutations are specified which the API is offering
 */
const typeDefinitions = `
  scalar Date

  type Tweet {
    id: String
    keywordType: String
    keyword: String
    created: String
    createdWeek: Int
    toUser: String
    language: String
    source: String
    message: String
    messagePrep: String
    latitude: String
    longitude: String
    retweetCount: Int
    favorited: Boolean
    favoriteCount: Int
    isRetweet: Boolean
    retweeted: Int
    author: TweetAuthor
    sentiment: TweetSentiment
    topic: TweetTopic
  }

  type TweetAuthor {
    id: String
    username: String
    screenname: String
    tweets: [Tweet]
  }

  type TweetSentiment {
    id: String
    sentiment: String
    sarcastic: Float
    emojiSentiment: Float
    emojiDesc: String
    rEnsemble: String
    pythonEnsemble: String
  }

  type TweetTopic {
    id: String
    topicId: String
    topicContent: String
    probability: Float
  }

  type FacebookProfile {
    id: String
    keyword: String
    name: String
    category: String
    likes: Int
    type: String
    posts: [FacebookPost]
  }

  type FacebookPost {
    id: String
    message: String
    story:String
    likes: Int
    link: String
    lang: String
    created: Date
    author: FacebookProfile
    comments: [FacebookComment]
    sentiment: FacebookSentiment
    topic: FacebookTopic
  }

  type FacebookComment {
    id: String
    message: String
    lang: String
    created: Date
  }

  type FacebookSentiment {
    id: String
    sentiment: String
    sarcastic: Float
    emojiSentiment: Float
    emojiDesc: String
    rEnsemble: String
    pythonEnsemble: String
  }

  type FacebookTopic {
    id: String
    topicId: String
    topicContent: String
    probability: Float
  }

  type Query {
    tweet(id: String): Tweet
    tweets(limit: Int, offset: Int, startDate: Date, endDate: Date): [Tweet]
    tweetAuthor(username: String): TweetAuthor
    tweetSentiment(id: String): TweetSentiment
    tweetTopic(id: String): TweetTopic
    tweetCount(startDate: Date, endDate: Date): Int
    facebookPost(id: String): FacebookPost
    facebookPosts(limit: Int, offset: Int, startDate: Date, endDate: Date): [FacebookPost]
    facebookProfile(id: String): FacebookProfile

  }

  schema {
      query: Query
  }
`;

export default [typeDefinitions];