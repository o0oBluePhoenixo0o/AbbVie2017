package nlp;

import opennlp.tools.doccat.DoccatFactory;
import opennlp.tools.doccat.DoccatModel;
import opennlp.tools.doccat.DocumentCategorizerME;
import opennlp.tools.doccat.DocumentSampleStream;
import opennlp.tools.ml.naivebayes.NaiveBayesTrainer;
import opennlp.tools.util.InputStreamFactory;
import opennlp.tools.util.ObjectStream;
import opennlp.tools.util.PlainTextByLineStream;
import opennlp.tools.util.TrainingParameters;
import org.apache.commons.io.FilenameUtils;
import utils.FileUtils;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.nio.file.Paths;

/**
 * Created by alexanderweiss on 18.03.17.
 */
public class OpenNLPCategorizer {
    DoccatModel model;


    /**
     * Train a model from the resource directory
     * @param fileName
     */
    public void trainModel(String fileName) {
        InputStream dataIn = null;
        try {
            InputStreamFactory inputStreamFactory = () -> new FileInputStream(fileName);

            ObjectStream lineStream = new PlainTextByLineStream(inputStreamFactory, Charset.forName("UTF-8"));
            ObjectStream sampleStream = new DocumentSampleStream(lineStream);

            // Specifies the minimum number of times a feature must be seen
            TrainingParameters params = new TrainingParameters();
            params.put(TrainingParameters.CUTOFF_PARAM, Integer.toString(2));
            params.put(TrainingParameters.ITERATIONS_PARAM, Integer.toString(30));
            params.put(TrainingParameters.ALGORITHM_PARAM, NaiveBayesTrainer.NAIVE_BAYES_VALUE);

            model = DocumentCategorizerME.train("en", sampleStream, params, new DoccatFactory());
            FileUtils.writeModelToFile(model, "./models/"+ FilenameUtils.getBaseName(fileName).toString()+"Model.bin");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (dataIn != null) {
                try {
                    dataIn.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public void classifyNewTweet(String tweet) {
        DocumentCategorizerME myCategorizer = new DocumentCategorizerME(model);
        double[] outcomes = myCategorizer.categorize(new StopWords().removeStopWords(tweet));
        String category = myCategorizer.getBestCategory(outcomes);

        if (category.equalsIgnoreCase("1")) {
            System.out.println("The tweet is positive :) ");
        } else {
            System.out.println("The tweet is negative :( ");
        }
    }
}