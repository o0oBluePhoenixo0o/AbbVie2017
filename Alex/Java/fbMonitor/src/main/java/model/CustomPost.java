package model;

import com.restfb.Facebook;

import java.util.ArrayList;
import java.util.Date;

/**
 * Created by alexanderweiss on 21.03.17.
 */
public class CustomPost {


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

    @Facebook("type")
    private String type;

    @Facebook("link")
    private String link;

    @Facebook("story")
    private String story;

    @Facebook("comments_count")
    private long comments_count;

    @Facebook("shares_count")
    private long shares_count;

    @Facebook("likesCount")
    private long likesCount;

    private String [] removedStopWords;

    private String [] posTags;




    private ArrayList<CustomComment> comments;


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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    public String getStory() {
        return story;
    }

    public void setStory(String story) {
        this.story = story;
    }

    public long getComments_count() {
        return comments_count;
    }

    public void setComments_count(long comments_count) {
        this.comments_count = comments_count;
    }

    public long getShares_count() {
        return shares_count;
    }

    public void setShares_count(long shares_count) {
        this.shares_count = shares_count;
    }

    public long getLikesCount() {
        return likesCount;
    }

    public void setLikesCount(long likesCount) {
        this.likesCount = likesCount;
    }

    public ArrayList<CustomComment> getComments() {
        return comments;
    }

    public void setComments(ArrayList<CustomComment> comments) {
        this.comments = comments;
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
