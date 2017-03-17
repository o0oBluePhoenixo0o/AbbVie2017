import com.github.opendevl.JFlat;
import com.restfb.*;
import com.restfb.types.Comment;
import com.restfb.types.Page;
import com.restfb.types.Post;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import utils.LanguageUtil;

import java.io.*;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
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
                        if(post.getMessage() !=null && !post.getMessage().contentEquals("") && !isValidURL(post.getMessage())){
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
                                reactionsJSON.add(reactionOnPostJSON);
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
                            if(comment.getMessage() !=null && !comment.getMessage().contentEquals("") && !isValidURL(comment.getMessage())){
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
                                    if(commentOnComment.getMessage() !=null && !commentOnComment.getMessage().contentEquals("") && !isValidURL(commentOnComment.getMessage())){
                                        commentOnCommentJSON.put("origLang",  languageUtil.detect(commentOnComment.getMessage()));
                                    } else {
                                        commentOnCommentJSON.put("origLang",  "");
                                    }

                                    //commentOnCommentJSON.put("lang": LANG)

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
        this.createDir("json");
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
        this.createDir("csv");
        flatMe.json2Sheet().write2csv("./csv/"+fileName+".csv");
    }

    public  boolean isValidURL(String urlString)
    {
        try
        {
            URL url = new URL(urlString);
            url.toURI();
            return true;
        } catch (Exception exception)
        {
            return false;
        }
    }

    private void createDir(String directoryName){
        Path path = Paths.get("./"+directoryName);
        if(!Files.exists(path)) {
            try {
                Files.createDirectories(path);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

}
