package nlp;


import model.CustomComment;
import model.CustomPage;
import model.CustomPost;
import nlp.pos.POSTagger;
import nlp.stopword.StopWords;

import utils.LanguageUtil;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by alexanderweiss on 19.03.17.
 */

//TODO Need to implement message translation, and lemmatizer
public class Preprocessor {

    private LanguageUtil languageUtil;
    private StopWords stopWords;
    private POSTagger posTagger;

    public Preprocessor(){
        this.languageUtil = new LanguageUtil();
        this.stopWords = new StopWords();
        this.posTagger = new POSTagger("./models/en-pos-maxent.bin");

    }

    /**
     * Pre process the pages data
     * @param pagesData
     * @return
     */
    public ArrayList<CustomPage> preProcessData(ArrayList<CustomPage> pagesData){

        ArrayList<CustomPage> preprocessedPages = new ArrayList<>();
        for (CustomPage page: pagesData) {
            ArrayList<CustomPost> preprocessedPosts = new ArrayList<>();

            for (CustomPost post: page.getPosts()) {
                preprocessedPosts.add(this.preProcessPost(post));
            }
            //Set the preprocessed posts to page
            page.setPosts(preprocessedPosts);
            preprocessedPages.add(page);
        }
        return preprocessedPages;
    }

    /**
     * Pre process the data of a post
     * 1. lower case
     * 2. detect language
     * 3. remove stopwords
     * 4. tag pos
     * @param post
     * @return
     */
    private CustomPost preProcessPost(CustomPost post){

        if (post.getMessage()!=null) {

            //lower case
            post.setMessage(post.getMessage().toLowerCase());

            //Detect language
            post.setLanguage(languageUtil.detect(post.getMessage()));

            //Remove Stopwords
            String [] removedStopWords = this.stopWords.removeStopWords(post.getMessage());
            post.setRemovedStopWords(removedStopWords);


            //Set POS tags
            String [] tags = this.posTagger.tagSentence(removedStopWords);
            post.setPosTags(tags);
        }

        ArrayList<CustomComment> preprocessedComments = new ArrayList<>();

        for (CustomComment comment: post.getComments()) {
            preprocessedComments.add(this.preProcessComment(comment));
        }

        post.setComments(preprocessedComments);
        return post;

    }

    /**
     * Pre process the data of a comment
     * 1. lower case
     * 2. detect language
     * 3. remove stopwords
     * 4. tag pos
     * @param comment
     * @return
     */
    private CustomComment preProcessComment(CustomComment comment){

        if(comment.getMessage()!=null) {

            //lower case
            comment.setMessage(comment.getMessage().toLowerCase());

            //detect language
            comment.setLanguage(languageUtil.detect(comment.getMessage()));

            //remove Stopwords
            String [] removedStopWords = this.stopWords.removeStopWords(comment.getMessage());
            comment.setRemovedStopWords(removedStopWords);

            //set POS tags
            String [] tags = this.posTagger.tagSentence(removedStopWords);
            comment.setPosTags(tags);
        }
        return comment;
    }


}
