import preprocessing.TextProcessing;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


/**
 * Created by alexanderweiss on 23.04.17.
 */
public class Start {



    public static void main(String [] args) throws IOException {
        /*Twitter twitter = new Twitter();
        twitter.writeTweetsToMalletFile(twitter.readTwitterTweets());*/

        Path path = Paths.get("tweets_sentiment_training.txt");
        Charset charset = StandardCharsets.UTF_8;

        String content = new String(Files.readAllBytes(path), charset);
        content = content.replaceAll(",", " ");
        Files.write(path, content.getBytes(charset));
    }
}
