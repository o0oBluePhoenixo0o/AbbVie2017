import com.github.opendevl.JFlat;
import com.restfb.*;
import com.restfb.types.Comment;
import com.restfb.types.Page;
import com.restfb.types.Post;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
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
        this.fbClient = new DefaultFacebookClient(accessToken, Version.VERSION_2_8);;
    }


    /**
     * Get a list of comments for a specific post id
     * @param post_id
     * @return
     */
    public List<Comment> getCommentsFromPost( String post_id){
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


    /**
     * Get all pages for a keyword from Facbook
     * @param keyWord
     * @return
     * @throws IOException
     */
    public JSONArray searchPagesData(String keyWord) throws IOException {

        JSONArray pagesJSON = new JSONArray();


        Connection<Page> pages =
                fbClient.fetchConnection("search", Page.class,
                        Parameter.with("q", keyWord), Parameter.with("type", "page"));

        ArrayList<Page> pagesList = new ArrayList<Page>();
        ArrayList<Post> postsList = new ArrayList<Post>();
        ArrayList<Comment> commentsList = new ArrayList<Comment>();

        System.out.println("Getting data...");


        for (List<Page> pagesConnection : pages) {
            for (Page page : pagesConnection) {
                pagesList.add(page);

                JSONObject pageJSON = new JSONObject();
                pageJSON.put("name", page.getName());
                pageJSON.put("id", page.getId());
                JSONArray postsJSON = new JSONArray();

                System.out.println(".page");
                Connection<Post> pageFeed = this.fbClient.fetchConnection(page.getId() + "/feed", Post.class);
                for (List<Post> pageFeedConnectionPage : pageFeed) {
                    for (Post post : pageFeedConnectionPage) {

                        JSONObject postJSON = new JSONObject();
                        postJSON.put("id", post.getId());
                        postJSON.put("message", post.getMessage());

                        JSONArray reactionsJSON = new JSONArray();
                        if (post.getReactions() != null){
                            post.getReactions().getData().forEach(reactionOnPost ->{
                                System.out.println(".reactionOnPost");
                                JSONObject reactionOnPostJSON =  new JSONObject();
                                reactionOnPostJSON.put("type", reactionOnPost.getType());
                                reactionOnPostJSON.put("name", reactionOnPost.getName());
                                reactionsJSON.add(reactionOnPostJSON);
                            });
                        }

                        postJSON.put("reactions", reactionsJSON);


                        JSONArray commentsJSON = new JSONArray();
                        System.out.println(".post");
                        this.getCommentsFromPost(post.getId()).forEach(comment ->{
                            JSONObject commentJSON = new JSONObject();
                            commentJSON.put("id", comment.getId());
                            commentJSON.put("message", comment.getMessage());
                            commentJSON.put("likes", comment.getLikeCount());

                            JSONArray commentsOnCommentJSON = new JSONArray();

                            if (comment.getComments() != null){
                                comment.getComments().getData().forEach(commentOnComment ->{
                                    System.out.println(".commentOncomment");
                                    JSONObject commentOnCommentJSON =  new JSONObject();
                                    commentOnCommentJSON.put("id", commentOnComment.getId());
                                    commentOnCommentJSON.put("message", commentOnComment.getMessage());
                                    commentsOnCommentJSON.add(commentOnComment);
                                });

                                commentJSON.put("comments", commentsOnCommentJSON);
                            } else {
                                commentJSON.put("comments", null);
                            }


                            commentsJSON.add(commentJSON);
                        });

                        postJSON.put("comments", commentsJSON);
                        postsJSON.add(postJSON);
                    }
                }
                pageJSON.put("posts", postsJSON);
                pagesJSON.add(pageJSON);
            }
        }
        return pagesJSON;
    }


    /**
     * Write a JSON string to a file
     * @param jsonString
     * @param fileName
     * @throws IOException
     */
    public void writeJSONToFile(String jsonString ,String fileName) throws IOException{
        FileWriter file = null;

        try  {
            file= new FileWriter(fileName+".json");
            file.write(jsonString);
            System.out.println("Successfully Copied JSON Object to File...");
        } catch (IOException ioe){
            ioe.printStackTrace();
        } finally {
            file.flush();
            file.close();
        }
    }

    /**
     * Convert JSON to CSV
     * @param jsonString
     * @param fileName
     * @throws IOException
     */
    public void writeJSONtoCSV(String jsonString ,String fileName) throws IOException {
        JFlat flatMe = new JFlat(jsonString);
        //directly write the JSON document to CSV
        flatMe.json2Sheet().write2csv("./csv/"+fileName+".csv");
    }

}
