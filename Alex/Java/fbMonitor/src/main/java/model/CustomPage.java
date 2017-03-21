package model;

import com.restfb.Facebook;

import java.util.ArrayList;

/**
 * Created by alexanderweiss on 21.03.17.
 */
public class CustomPage {

    @Facebook("id")
    private String id;

    @Facebook("name")
    private String name;

    private String keyword;

    private ArrayList<CustomPost> posts;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public ArrayList<CustomPost> getPosts() {
        return posts;
    }

    public void setPosts(ArrayList<CustomPost> posts) {
        this.posts = posts;
    }
}
