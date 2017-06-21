import com.opencsv.CSVParser;
import com.opencsv.CSVReader;
import model.Tweet;

import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * Created by alexanderweiss on 23.04.17.
 */
public class Twitter {




    public ArrayList<Tweet> readTwitterTweets() throws IOException {

        ArrayList<Tweet> tweets = new ArrayList<>();

        CSVReader reader = new CSVReader(new FileReader(this.getClass().getResource("Final_TW_2605_prep.csv").getFile()), CSVParser.DEFAULT_SEPARATOR,
                CSVParser.DEFAULT_QUOTE_CHARACTER, 1);
        String[] nextLine;
        while ((nextLine = reader.readNext()) != null) {
            // nextLine[] is an array of values from the line
            /*System.out.println(nextLine[0] + " " + nextLine[1] + " " + nextLine[2] + " " + nextLine[3] + " " + nextLine[4]
                    + " " + nextLine[5] + " " + nextLine[6] + " " + nextLine[7] + " " + nextLine[8] + " " + nextLine[9]
                    + " " + nextLine[10] + " " + nextLine[11]  + " " + nextLine[12]  + " " + nextLine[13]  + " " + nextLine[14]
                    + " " + nextLine[15]  + " " + nextLine[16]  + " " + nextLine[17]);*/



            //"key","created_time","From.User","From.User.Id","To.User","To.User.Id","Language","Source","message","Geo.Location.Latitude","Geo.Location.Longitude","Retweet.Count","Id","favorited","favoriteCount","isRetweet","retweeted"
            String key = nextLine[0];
            String created_time = nextLine[1];
            String fromUserName = nextLine[2];
            String fromUserId = nextLine[3];
            String toUserName = nextLine[4];
            String toUserId = nextLine[5];
            String language = nextLine[6];
            String source = nextLine[7];
            String message = nextLine[8];
            String latitude = nextLine[9];
            String longitude = nextLine[10];

            int retweetCount = 0;
            try {
                retweetCount = Integer.parseInt(nextLine[11]);
            } catch (NumberFormatException nife) {
                retweetCount = 0;
            }

            String id = nextLine[12];
            String favorited = nextLine[13];
            int favoriteCount = 0;
            try {
                favoriteCount = Integer.parseInt(nextLine[14]);
            } catch (NumberFormatException nife) {
                favoriteCount = 0;
            }
            boolean isRetweeted = Boolean.valueOf(nextLine[15]);
            boolean retweeted = Boolean.valueOf(nextLine[16]);
            System.out.println(id);

            Tweet tweet = new Tweet(created_time, fromUserName, fromUserId, toUserName, toUserId, language,
                    source, message, latitude, longitude, retweetCount, id, key, favorited, favoriteCount, isRetweeted
                    , retweeted);
            tweets.add(tweet);
        }
        return tweets;
    }

    public void writeTweetsToMalletFile(ArrayList<Tweet> tweets){
        tweets.forEach((tweet)->{
            String writeToFile = tweet.getId() + " " + "X" + " " + tweet.getMessage();
            System.out.println("Write '" +  writeToFile + "' to file");
            BufferedWriter bw = null;

            try {
                // APPEND MODE SET HERE
                bw = new BufferedWriter(new FileWriter("tweets.txt", true));
                bw.write(writeToFile);
                bw.newLine();
                bw.flush();
            } catch (IOException ioe) {
                ioe.printStackTrace();
            } finally {                       // always close the file
                if (bw != null) try {
                    bw.close();
                } catch (IOException ioe2) {
                    // just ignore it
                }
            } // end try/catch/finally
        });
    }


}
