
import model.CustomPage;
import nlp.Preprocessor;
import nlp.pos.POSTagger;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by alexanderweiss on 02.03.17.
 */
public class Main {




    public static void main (String [] args) {

        FacebookMonitor facebookMonitor = new FacebookMonitor("EAACEdEose0cBADBOvQEzsa2l1BzcAJetpRSYHppdXWEX382lsYqEBcjKSKBz0iAI6S8gJiZBZB8SxBEpOTzH8CLoWohZAyD04UYGNuIDZBsQhYAEZA2f8ZAZBSj2BtRjTnni37ZAlgxiROpMZCtMZA6AEMNOzzleDsby1PQ0pKJ68nx2qKOaNgdXsVRqYBgJhyfSsZD");

        try {
           /* ArrayList<CustomPage> humiraPages = facebookMonitor.searchPagesDataObject("Humira");
            ArrayList<CustomPage> enbrelPages = facebookMonitor.searchPagesDataObject("Enbrel");
            ArrayList<CustomPage> adalimumabPages = facebookMonitor.searchPagesDataObject("Adalimumab");
            ArrayList<CustomPage> trilipixPages = facebookMonitor.searchPagesDataObject("Trilipix");
           */

            ArrayList<CustomPage> imbruvicaPages = facebookMonitor.searchPagesDataObject("Imbruvica");
            Preprocessor preprocessor = new Preprocessor();
            ArrayList<CustomPage> preprocessedImbruvicaPages = preprocessor.preProcessData(imbruvicaPages);

        } catch (IOException e) {
            e.printStackTrace();
        }

        /*
        OpenNLPCategorizer twitterCategorizer = new OpenNLPCategorizer();
        twitterCategorizer.trainModel("./training/tweets.txt");
        twitterCategorizer.classifyNewTweet(new StopWords().removeStopWords("I hate this product")); //out: "This tweet is negative"

        StopWords stopWords = new StopWords();
        String [] removedStopWords = stopWords.removeStopWords("Hello I will learn how to use Humira today".toLowerCase());
        Arrays.stream(removedStopWords).forEach(System.out::println);


        POSTagger posTagger = new POSTagger("./models/en-pos-maxent.bin");
        Arrays.stream(posTagger.tagSentence(new String[]{"Most", "large", "cities", "in", "the", "US", "had",
                "morning", "and", "afternoon", "newspapers", "."})).forEach(System.out::println);*/
    }
}
