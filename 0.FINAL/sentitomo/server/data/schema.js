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
    author: Author
    sentiment: Sentiment
    topic: Topic
  }

  type Author {
    id: String
    username: String
    screenname: String
    tweets: [Tweet]
  }

  type Sentiment {
    id: String
    sentiment: String
  }

  type Topic {
    id: String
    topic1Month: String
    topic1Month_C: String
    topic3Month: String
    topic3Month_C: String
    topicWhole: String
    topicWhole: String
  }

  type Query {
    tweet(id: String): Tweet
    sentiment(id: String): Sentiment
    topic(id: String): Topic
    author(username: String): Author
    tweets(limit: Int, offset:Int, startDate: Date, endDate: Date): [Tweet]
  }

  schema {
      query: Query
  }
`;

export default [typeDefinitions];