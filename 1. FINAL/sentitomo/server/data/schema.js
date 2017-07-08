const typeDefinitions = `
  type Tweet {
    id: String
    message: String
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
  }

  schema {
      query: Query
  }
`;

export default [typeDefinitions];