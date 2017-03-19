
import nlp.OpenNLPCategorizer;
import nlp.StopWords;

/**
 * Created by alexanderweiss on 02.03.17.
 */
public class Main {




    public static void main (String [] args) {

        FacebookMonitor facebookMonitor = new FacebookMonitor("EAACEdEose0cBAHnZCPG7ie6NXpaeOrX1js8ALIZAO1uMWZC54c2X3Mjx2XXrh1ZBrZAtyBPCK9N3wZAmzvF9lQDFLPMHNlG1hCCgR44otTKPTjwmi3mBSlcgOCjonBKHsQ3salb6sTZCfBRbTpoVU86bl8y0N2oAAUML3g0fyTpGrMb2gB3iVF7OEyZBvvQZC35MZD");
    /*
        try {

            JSONArray humiraJSON = facebookMonitor.searchPagesData("Humira");
            JSONArray adalimumabJSON = facebookMonitor.searchPagesData("Adalimumab");
            JSONArray enbrelJSON = facebookMonitor.searchPagesData("Enbrel");
            JSONArray trilipixJSON = facebookMonitor.searchPagesData("Trilipix");
            JSONArray imbruvicaJSON = facebookMonitor.searchPagesData("Imbruvica");


            FileUtils.writeJSONToFile(humiraJSON.toString(), "humiraPages");
            FileUtils.writeJSONToFile(adalimumabJSON.toString(), "adalimumabPages");
            FileUtils.writeJSONToFile(enbrelJSON.toString(), "enbrelPages");
            FileUtils.writeJSONToFile(trilipixJSON.toString(), "trilipixPages");
            FileUtils.writeJSONToFile(imbruvicaJSON.toString(), "imbruvicaPages");


            FileUtils.writeJSONtoCSV(humiraJSON.toString(), "humiraPages");
            FileUtils.writeJSONtoCSV(adalimumabJSON.toString(), "adalimumabPages");
            FileUtils.writeJSONtoCSV(enbrelJSON.toString(), "enbrelPages");
            FileUtils.writeJSONtoCSV(trilipixJSON.toString(), "trilipixPages");
            FileUtils.writeJSONtoCSV(imbruvicaJSON.toString(), "imbruvicaPages");
        } catch (Exception e) {
            e.printStackTrace();
        }

        JSONArray humiraPages = FileUtils.readJSONArray("./json/humiraPages.json");
        JSONArray adalimumabPages = FileUtils.readJSONArray("./json/adalimumabPages.json");
        JSONArray enbrelPages = FileUtils.readJSONArray("./json/enbrelPages.json");
        JSONArray trilipixPages = FileUtils.readJSONArray("./json/trilipixPages.json");
        JSONArray imbruvicaPages = FileUtils.readJSONArray("./json/imbruvicaPages.json");


        try {
            FileUtils.writeJSONToFile(FileUtils.concatJSONArrays(humiraPages,adalimumabPages,enbrelPages,trilipixPages,imbruvicaPages).toString(),"masterProducts.json");
            FileUtils.writeJSONtoCSV(FileUtils.readJSONArray("./json/masterProducts.json").toString(),"masterProducts.csv");
        } catch (IOException e) {
            e.printStackTrace();
        }

        */

        OpenNLPCategorizer twitterCategorizer = new OpenNLPCategorizer();
        twitterCategorizer.trainModel("/training/tweets.txt");
        twitterCategorizer.classifyNewTweet("I hate this product"); //out: "This tweet is negative"

        StopWords stopWords = new StopWords();
        System.out.println(stopWords.removeStopWords("Hello I will learn how to use Humira today".toLowerCase()));
    }
}
