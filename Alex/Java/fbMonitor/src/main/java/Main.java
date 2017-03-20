
import nlp.OpenNLPCategorizer;
import nlp.StopWords;

import java.util.Arrays;

/**
 * Created by alexanderweiss on 02.03.17.
 */
public class Main {




    public static void main (String [] args) {

        FacebookMonitor facebookMonitor = new FacebookMonitor("EAACEdEose0cBAHnZCPG7ie6NXpaeOrX1js8ALIZAO1uMWZC54c2X3Mjx2XXrh1ZBrZAtyBPCK9N3wZAmzvF9lQDFLPMHNlG1hCCgR44otTKPTjwmi3mBSlcgOCjonBKHsQ3salb6sTZCfBRbTpoVU86bl8y0N2oAAUML3g0fyTpGrMb2gB3iVF7OEyZBvvQZC35MZD");

        OpenNLPCategorizer twitterCategorizer = new OpenNLPCategorizer();
        twitterCategorizer.trainModel("./training/tweets.txt");
        twitterCategorizer.classifyNewTweet("I hate this product"); //out: "This tweet is negative"

        StopWords stopWords = new StopWords();
        String [] removedStopWords = stopWords.removeStopWords("Hello I will learn how to use Humira today".toLowerCase());
        Arrays.stream(removedStopWords).forEach(System.out::println);
    }
}
