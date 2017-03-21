package model;

import com.restfb.Facebook;

import java.util.Date;

/**
 * Created by alexanderweiss on 21.03.17.
 */
public class CustomComment {


    @Facebook("id")
    private String id;

    @Facebook("from_id")
    private String from_id;

    @Facebook("from_name")
    private String from_name;

    @Facebook("message")
    private String message;

    private String language;

    @Facebook("created_time")
    private String created_time;

    @Facebook("comments_count")
    private long comments_count;

    @Facebook("likesCount")
    private long likesCount;

    private String [] removedStopWords;

    private String [] posTags;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getFrom_id() {
        return from_id;
    }

    public void setFrom_id(String from_id) {
        this.from_id = from_id;
    }

    public String getFrom_name() {
        return from_name;
    }

    public void setFrom_name(String from_name) {
        this.from_name = from_name;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getCreated_time() {
        return created_time;
    }

    public void setCreated_time(String created_time) {
        this.created_time = created_time;
    }

    public long getComments_count() {
        return comments_count;
    }

    public void setComments_count(long comments_count) {
        this.comments_count = comments_count;
    }

    public long getLikesCount() {
        return likesCount;
    }

    public void setLikesCount(long likesCount) {
        this.likesCount = likesCount;
    }

    public String[] getRemovedStopWords() {
        return removedStopWords;
    }

    public void setRemovedStopWords(String[] removedStopWords) {
        this.removedStopWords = removedStopWords;
    }

    public String[] getPosTags() {
        return posTags;
    }

    public void setPosTags(String[] posTags) {
        this.posTags = posTags;
    }
}
