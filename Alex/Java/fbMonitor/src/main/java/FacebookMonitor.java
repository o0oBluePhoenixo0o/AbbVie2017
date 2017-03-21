import com.github.opendevl.JFlat;
import com.restfb.*;
import com.restfb.types.Comment;
import com.restfb.types.Page;
import com.restfb.types.Post;
import com.restfb.types.Reactions;
import model.CustomComment;
import model.CustomPage;
import model.CustomPost;
import org.json.JSONArray;
import org.json.JSONObject;
import utils.LanguageUtil;
import utils.Validator;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by alexanderweiss on 07.03.17.
 */
public class FacebookMonitor {



    private String accessToken;
    private FacebookClient fbClient;

    /**
     * Default constructor
     * @param accessToken
     */
    public FacebookMonitor(String accessToken){
        this.accessToken = accessToken;
        this.fbClient = new DefaultFacebookClient(this.accessToken, Version.VERSION_2_8);;
    }

    /*

    /**
     * Get all pages for a keyword from Facbook and already apply the language tag to it
     * @param keyWord
     * @return
     * @throws IOException
     */
    public ArrayList<CustomPage> searchPagesDataObject(String keyWord) throws IOException {

        ArrayList<CustomPage> allPages = new ArrayList<>();

        Connection<CustomPage> pages =fbClient.fetchConnection("search", CustomPage.class, Parameter.with("q", keyWord), Parameter.with("type", "page"));
        System.out.println("Getting data for keyword..." + keyWord);

        for (List<CustomPage> pagesConnection : pages) {
            for (CustomPage page : pagesConnection) {
                System.out.println(".page");
                page.setKeyword(keyWord);
                ArrayList<CustomPost> posts = new ArrayList<>();

                Connection<CustomPost> pageFeed = this.fbClient.fetchConnection(page.getId() + "/feed", CustomPost.class);
                for (List<CustomPost> pageFeedConnectionPage : pageFeed) {
                    for (CustomPost post : pageFeedConnectionPage) {
                        System.out.println(".post: " + post.getId() );

                        post.setComments(this.getCommentsFromPost(post.getId()));
                        posts.add(post);
                    }
                }
                page.setPosts(posts);
                allPages.add(page);
            }
        }
        return allPages;
    }




    /**
     * Get a list of comments for a specific post id
     * @param post_id
     * @return
     */
    private ArrayList<CustomComment> getCommentsFromPost(String post_id){
        ArrayList<CustomComment> comments = new ArrayList<CustomComment>();

        Connection<CustomComment> allComments = this.fbClient.fetchConnection(post_id+"/comments", CustomComment.class);

        // Iterate over the feed to access the particular pages
        for (List<CustomComment> comments1 : allComments) {

            // Iterate over the list of contained data
            // to access the individual object
            for (CustomComment comment : comments1) {
                comments.add(comment);
                System.out.println(".comment");
            }
        }

        return comments;
    }
}
