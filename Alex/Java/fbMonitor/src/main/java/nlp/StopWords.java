package nlp;

import opennlp.tools.tokenize.SimpleTokenizer;
import opennlp.tools.tokenize.WhitespaceTokenizer;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

/**
 * Created by alexanderweiss on 19.03.17.
 * Class for handling stopwords (en!)
 */
public class StopWords {


    private String [] defaultStopWords = { "i", "a", "about", "an",
            "are", "as", "at", "by", "com", "for", "from", "how",
            "in", "is", "it", "of", "on", "or", "that", "the", "this",
            "to", "was", "what", "when", "where", "who", "will", "with"
    };

    private static HashSet stopWords = new HashSet();

    /**
     * Default constructor, uses default stopwords
     */
    public StopWords(){
        stopWords.addAll(Arrays.asList(defaultStopWords));
    }

    /**
     * Use stopwords stored in a file
     * @param fileName
     */
    public StopWords(String fileName){
        try {
            BufferedReader bufferedReader = new BufferedReader(new FileReader(fileName));
            while (bufferedReader.ready()){
                stopWords.add(bufferedReader.readLine());
            }
        } catch (IOException ioe){
            ioe.printStackTrace();
        }
    }

    /**
     * Add a word to the stopword list
     * @param word
     */
    public void addStopWord(String word){
        stopWords.add(word);
    }

    /**
     * Remove stopwords from a sentence
     * @param sentence
     * @return
     */
    public String removeStopWords(String sentence){

        SimpleTokenizer simpleTokenizer= SimpleTokenizer.INSTANCE;
        String[] words = simpleTokenizer.tokenize(sentence);
        ArrayList<String> tokens = new ArrayList<>(Arrays.asList(words));

        for (int i = 0; i<tokens.size(); i++){
            if (stopWords.contains(tokens.get(i))) {
                tokens.remove(i);
            }
        }

        StringBuilder stringBuilder = new StringBuilder();
        tokens.forEach(word -> stringBuilder.append(word + " "));
        return stringBuilder.toString().trim();
    }
}
