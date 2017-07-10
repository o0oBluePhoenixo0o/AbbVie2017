const typeDefinitions = `
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
  }

  type Author {
    id: String
    username: String
    screenname: String
    tweets: [Tweet]
  }

  type Query {
    tweet(id: String): Tweet
    author(username: String): Author
    tweets: [Tweet]
  }

  schema {
      query: Query
  }
`;