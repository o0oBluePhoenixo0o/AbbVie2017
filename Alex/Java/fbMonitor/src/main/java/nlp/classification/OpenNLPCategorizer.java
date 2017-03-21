package nlp.classification;

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



    private DoccatModel model;
    private DocumentCategorizerME categorizer;


    /**
     * Default constructor, load or train model manually
     */
    public OpenNLPCategorizer(){
    }

    /**
     * Constructor which automatically loads a model from file
     * @param categoryModelFile
     */
    public OpenNLPCategorizer(String categoryModelFile){
        this.loadCategoryModelFromFile(categoryModelFile);
    }

    /**
     * Train a model from a file and have the option to save it to models directory for later usage
     * @param trainingDataFileName
     */
    public void trainModel(String trainingDataFileName, boolean save) {
        InputStream dataIn = null;
        try {
            InputStreamFactory inputStreamFactory = () -> new FileInputStream(trainingDataFileName);

            ObjectStream lineStream = new PlainTextByLineStream(inputStreamFactory, Charset.forName("UTF-8"));
            ObjectStream sampleStream = new DocumentSampleStream(lineStream);

            // Specifies the minimum number of times a feature must be seen
            TrainingParameters params = new TrainingParameters();
            params.put(TrainingParameters.CUTOFF_PARAM, Integer.toString(2));
            params.put(TrainingParameters.ITERATIONS_PARAM, Integer.toString(30));
            params.put(TrainingParameters.ALGORITHM_PARAM, NaiveBayesTrainer.NAIVE_BAYES_VALUE);

            this.model = DocumentCategorizerME.train("en", sampleStream, params, new DoccatFactory());

            if(save) {
                FileUtils.writeModelToFile(this.model, "./models/" + FilenameUtils.getBaseName(trainingDataFileName).toString() + "Model.bin");
            }
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

    /**
     * Load a category model from file
     * @param categoryModelFile
     */
    public void loadCategoryModelFromFile(String categoryModelFile){
        InputStream modelIn = null;

        try {
            modelIn = new FileInputStream(categoryModelFile);
            this.model = new DoccatModel(modelIn);
            this.categorizer = new DocumentCategorizerME(this.model);
        }
        catch (IOException e) {
            // Model loading failed, handle the error
            e.printStackTrace();
        }
        finally {
            if (modelIn != null) {
                try {
                    modelIn.close();
                }
                catch (IOException e) {
                }
            }
        }
    }

    /**
     * Classify a sentence
     * @param sentence
     */
    public void classifySentence(String [] sentence) {
        double[] outcomes = this.categorizer.categorize(sentence);
        String category = this.categorizer.getBestCategory(outcomes);

        if (category.equalsIgnoreCase("1")) {
            System.out.println("The tweet is positive :) ");
        } else {
            System.out.println("The tweet is negative :( ");
        }
    }
}