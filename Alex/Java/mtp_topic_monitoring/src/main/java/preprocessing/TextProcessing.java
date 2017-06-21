package preprocessing;


import opennlp.tools.stemmer.PorterStemmer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;

/**
 * Created by alexanderweiss on 23.04.17.
 */
public class TextProcessing {

    private static String[] stopWords = new String[] {
            "a", "all", "am", "an", "and", "any", "are", "aren't",
            "as", "at", "be", "because", "been", "to", "from", "by",
            "can", "can't", "do", "don't", "didn't", "did", "the", "is" };

    /**
     * Stems a String
     * @param term
     * @return Stemmed String
     */
    public static String stemTerm(String term) {
        PorterStemmer stemmer = new PorterStemmer();
        return stemmer.stem(term);
    }

    /**
     * Remove stop words from a String
     * @param term
     * @return String
     */
    public static String removeStopWords(String term) {
        Arrays.sort(stopWords, Comparator.comparingInt(String::length));
        ArrayList<String> wordsList = new ArrayList<String>();

        StringBuilder stringBuilder = new StringBuilder();

        term = term.trim().replaceAll("\\s+", " ").toLowerCase();
        String[] words = term.split(" ");

        for (String word : words) {
            wordsList.add(word);
        }
        for (int j = 0; j < stopWords.length; j++) {
            if (wordsList.contains(stopWords[j])) {
                wordsList.remove(stopWords[j]);
            }
        }
        for (String str : wordsList) {
            stringBuilder.append(str + " ");
        }

        return stringBuilder.toString().trim();

    }

}
