import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;


/**
 * @author alexanderweiss
 * @date 09.05.17.
 * This class can be used to crawl abbreviations from different sources.
 */

public class CrawlAbbrev {

    private static String outputFileName = "abbrev.csv"; // the output file where the abbreviations are stored
    /**
     * Crawl all common abbreviations from http://public.oed.com/how-to-use-the-oed/abbreviations/
     * @throws IOException Thrown if something fails on reading content from the website or writing data to the abbreviation file
     */
    public void crawlCommonAbbrev() throws IOException {
        Document doc = Jsoup.connect("http://public.oed.com/how-to-use-the-oed/abbreviations/").userAgent("Safari").get();

        Elements body = doc.select("body");
        Elements trs = body.get(0).getElementsByTag("tr");
        for (Element tr : trs) {

            // Assume default encoding.
            FileWriter fileWriter = new FileWriter(this.outputFileName,true);

            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

            Elements tds = tr.getElementsByTag("td");

            if(tds.size() > 1){
                String abbrev = tds.get(0).text();
                String full = tds.get(1).text();


                bufferedWriter.write('"' + abbrev + '"'+ ','+ '"' + full + '"');
                bufferedWriter.newLine();
                bufferedWriter.close();
            } else {
                System.out.print(tds.get(0).text() + "\n");
            }
        }
    }

    /**
     * Crawl all medical abbreviations from https://patient.info/doctor/abbreviations"
     * @throws IOException Thrown if something fails on reading content from the website or writing data to the abbreviation file
     */
    public void crawlMedicalAbbrev() throws IOException {
        Document doc = Jsoup.connect("https://patient.info/doctor/abbreviations").userAgent("Safari").get();

        Elements body = doc.select("body");
        Elements trs = body.get(0).getElementsByTag("tr");
        for (Element tr : trs) {

            // Assume default encoding.
            FileWriter fileWriter = new FileWriter(outputFileName,true);

            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

            Elements tds = tr.getElementsByTag("td");

            if(tds.size() > 1){
                String abbrev = tds.get(0).text();
                String full = tds.get(1).text();


                bufferedWriter.write('"' + abbrev + '"'+ ','+ '"' + full + '"');
                bufferedWriter.newLine();
                bufferedWriter.close();
            } else {
                System.out.print(tds.get(0).text() + "\n");
            }
        }
    }

    /**
     * Crawl all slang abbreviation froms http://www.netlingo.com/acronyms.php
     * @throws IOException Thrown if something fails on reading content from the website
     */
    public void crawlSlangAbbrev() throws IOException {

        Document doc = Jsoup.connect("http://www.netlingo.com/acronyms.php").userAgent("Safari").get();
        Elements body = doc.select("body");
        Elements lis = body.get(0).getElementsByTag("li");
        for (Element li : lis) {

            // Assume default encoding.
            FileWriter fileWriter = new FileWriter(outputFileName,true);

            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

            String abbrev = li.getElementsByTag("a").get(0).text().replace("#","'");
            String full = li.ownText();

            if(abbrev.equals("^URS")) {
                System.out.println("END");
                bufferedWriter.write('"' + abbrev + '"'+ ','+ '"' + full + '"');
                bufferedWriter.newLine();
                bufferedWriter.close();
                return;
            } else {
                bufferedWriter.write('"' + abbrev + '"'+ ','+ '"' + full + '"');
                bufferedWriter.newLine();
                bufferedWriter.close();
            }

        }
    }


    /**
     * Crawl all emojis from http://www.techdictionary.com/emoticon.html
     * @throws IOException Thrown if something fails on reading content from the website or writing data to the abbreviation file
     */
    public void crawlEmojis() throws IOException {


        // Emojis are separated on different sites
        String [] urls = {"http://www.techdictionary.com/emoticon.html",
                "http://www.techdictionary.com/emoticon_cont1.html",
                "http://www.techdictionary.com/emoticon_cont2.html",
                "http://www.techdictionary.com/emoticon_cont3.html"
        };

        for (String url : urls){
            Document doc = Jsoup.connect(url).userAgent("Safari").get();

            Elements body = doc.select("body");
            Elements tables = body.get(0).getElementsByTag("table");

            for(Element table: tables){
                if (table.className().equals("security") || table.className().equals("textleft")) {
                    Elements trs = table.getElementsByTag("tr");

                    for (Element tr : trs) {

                        // Assume default encoding.
                        FileWriter fileWriter = new FileWriter(outputFileName, true);

                        BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

                        Elements tds = tr.getElementsByTag("td");

                        if (tds.size() > 1) {
                            String abbrev = tds.get(1).text();
                            String full = tds.get(0).text();
                            System.out.println(abbrev + ":::::" + full);

                            bufferedWriter.write('"' + abbrev + '"'+ ','+ '"' + full + '"');
                            bufferedWriter.newLine();
                            bufferedWriter.close();
                        } else {
                            System.out.print(tds.get(0).text() + "\n");
                        }

                    }
                }
            }
        }
    }

    public static void main (String [] args) throws IOException {
        CrawlAbbrev abbrev = new CrawlAbbrev();
        abbrev.crawlCommonAbbrev();
        abbrev.crawlMedicalAbbrev();
        abbrev.crawlSlangAbbrev();
        abbrev.crawlEmojis();
    }
}

