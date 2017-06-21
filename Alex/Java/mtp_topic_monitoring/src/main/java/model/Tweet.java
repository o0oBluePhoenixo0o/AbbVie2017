package model;

/**
 * Created by alexanderweiss on 23.04.17.
 */

public class Tweet {

    private String created_time;
    private String fromUserName;
    private String fromUserId;
    private String toUserName;
    private String toUserId;
    private String language;
    private String source;
    private String message;
    private String latitude;
    private String longitude;
    private int retweetCount;
    private String id;
    private String key;
    private String favorited;
    private int favoriteCount;
    private boolean isRetweet;
    private boolean retweeted;

    public Tweet(String created_time, String fromUserName, String fromUserId, String toUserName, String toUserId, String language, String source, String message, String latitude, String longitude, int retweetCount, String id, String key, String favorited, int favoriteCount, boolean isRetweet, boolean retweeted) {
        this.created_time = created_time;
        this.fromUserName = fromUserName;
        this.fromUserId = fromUserId;
        this.toUserName = toUserName;
        this.toUserId = toUserId;
        this.language = language;
        this.source = source;
        this.message = message;
        this.latitude = latitude;
        this.longitude = longitude;
        this.retweetCount = retweetCount;
        this.id = id;
        this.key = key;
        this.favorited = favorited;
        this.favoriteCount = favoriteCount;
        this.isRetweet = isRetweet;
        this.retweeted = retweeted;
    }

    public String getCreatedTime() {
        return created_time;
    }

    public String getFromUserName() {
        return fromUserName;
    }

    public String getFromUserId() {
        return fromUserId;
    }

    public String getToUserName() {
        return toUserName;
    }

    public String getToUserId() {
        return toUserId;
    }

    public String getLanguage() {
        return language;
    }

    public String getSource() {
        return source;
    }

    public String getMessage() {
        return message;
    }

    public String getLatitude() {
        return latitude;
    }

    public String getLongitude() {
        return longitude;
    }

    public int getRetweetCount() {
        return retweetCount;
    }

    public String getId() {
        return id;
    }

    public String getKey() {
        return key;
    }

    public String getFavorited() {
        return favorited;
    }

    public int getFavoriteCount() {
        return favoriteCount;
    }

    public boolean isRetweet() {
        return isRetweet;
    }

    public boolean isRetweeted() {
        return retweeted;
    }

}
