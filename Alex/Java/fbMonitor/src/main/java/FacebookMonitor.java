import com.github.opendevl.JFlat;
import com.restfb.*;
import com.restfb.types.Comment;
import com.restfb.types.Page;
import com.restfb.types.Post;
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
    private LanguageUtil languageUtil;

    /**
     * Default constructor
     * @param accessToken
     */
    public FacebookMonitor(String accessToken){
        this.accessToken = accessToken;
        this.fbClient = new DefaultFacebookClient(accessToken, Version.VERSION_2_8);;
        this.languageUtil = new LanguageUtil();
    }

    /**
     * Get all pages for a keyword from Facbook and already apply the language tag to it
     * @param keyWord
     * @return
     * @throws IOException
     */
    public JSONArray searchPagesData(String keyWord) throws IOException {

        JSONArray pagesJSON = new JSONArray();


        Connection<Page> pages =
                fbClient.fetchConnection("search", Page.class,
                        Parameter.with("q", keyWord), Parameter.with("type", "page"));
        System.out.println("Getting data for keyword..." + keyWord);

        for (List<Page> pagesConnection : pages) {
            for (Page page : pagesConnection) {
                JSONObject pageJSON = new JSONObject();
                pageJSON.put("name", page.getName());
                pageJSON.put("id", page.getId());
                pageJSON.put("keyword" , keyWord);
                JSONArray postsJSON = new JSONArray();

                System.out.println(".page");
                Connection<Post> pageFeed = this.fbClient.fetchConnection(page.getId() + "/feed", Post.class);
                for (List<Post> pageFeedConnectionPage : pageFeed) {
                    for (Post post : pageFeedConnectionPage) {

                        JSONObject postJSON = new JSONObject();
                        postJSON.put("id", post.getId());
                        postJSON.put("message", post.getMessage());
                        if(post.getMessage() !=null && !post.getMessage().contentEquals("") && !Validator.isValidURL(post.getMessage())){
                            postJSON.put("origLang",  languageUtil.detect(post.getMessage()));
                        } else {
                            postJSON.put("origLang",  "");
                        }
                        //postJSON.put("lang": LANG)

                        //Get reactions on the post
                        JSONArray reactionsJSON = new JSONArray();
                        if (post.getReactions() != null){
                            post.getReactions().getData().forEach(reactionOnPost ->{
                                System.out.println(".reactionOnPost");
                                JSONObject reactionOnPostJSON =  new JSONObject();
                                reactionOnPostJSON.put("type", reactionOnPost.getType());
                                reactionOnPostJSON.put("name", reactionOnPost.getName());
                                reactionsJSON.put(reactionOnPostJSON);
                            });
                        }
                        postJSON.put("reactions", reactionsJSON);


                        //Get the comments on that post
                        JSONArray commentsJSON = new JSONArray();
                        System.out.println(".post");
                        this.getCommentsFromPost(post.getId()).forEach(comment ->{
                            JSONObject commentJSON = new JSONObject();
                            commentJSON.put("id", comment.getId());
                            commentJSON.put("message", comment.getMessage());
                            commentJSON.put("likes", comment.getLikeCount());
                            if(comment.getMessage() !=null && !comment.getMessage().contentEquals("") && !Validator.isValidURL(comment.getMessage())){
                                commentJSON.put("origLang",  languageUtil.detect(comment.getMessage()));
                            } else {
                                commentJSON.put("origLang",  "");
                            }
                            //commentJSON.put("lang": LANG)

                            JSONArray commentsOnCommentJSON = new JSONArray();

                            if (comment.getComments() != null){
                                comment.getComments().getData().forEach(commentOnComment ->{
                                    System.out.println(".commentOncomment");
                                    JSONObject commentOnCommentJSON =  new JSONObject();
                                    commentOnCommentJSON.put("id", commentOnComment.getId());
                                    commentOnCommentJSON.put("message", commentOnComment.getMessage());
                                    if(commentOnComment.getMessage() !=null && !commentOnComment.getMessage().contentEquals("") && !Validator.isValidURL(commentOnComment.getMessage())){
                                        commentOnCommentJSON.put("origLang",  languageUtil.detect(commentOnComment.getMessage()));
                                    } else {
                                        commentOnCommentJSON.put("origLang",  "");
                                    }

                                    //commentOnCommentJSON.put("lang": LANG)

                                    commentsOnCommentJSON.put(commentOnComment);
                                });

                                commentJSON.put("comments", commentsOnCommentJSON);
                            } else {
                                commentJSON.put("comments", new JSONArray());
                            }


                            commentsJSON.put(commentJSON);
                        });

                        postJSON.put("comments", commentsJSON);
                        postsJSON.put(postJSON);
                    }
                }
                pageJSON.put("posts", postsJSON);
                pagesJSON.put(pageJSON);
            }
        }
        return pagesJSON;
    }

    /**
     * Get a list of comments for a specific post id
     * @param post_id
     * @return
     */
    private List<Comment> getCommentsFromPost( String post_id){
        List<Comment> comments = new ArrayList<Comment>();

        Connection<Comment> allComments = this.fbClient.fetchConnection(post_id+"/comments", Comment.class);

        // Iterate over the feed to access the particular pages
        for (List<Comment> comments1 : allComments) {

            // Iterate over the list of contained data
            // to access the individual object
            for (Comment comment : comments1) {
                comments.add(comment);
                System.out.println(".comment");
            }
        }

        return comments;
    }
}
