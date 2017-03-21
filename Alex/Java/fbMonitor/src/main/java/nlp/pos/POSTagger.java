package nlp.pos;

import opennlp.tools.postag.POSModel;
import opennlp.tools.postag.POSSample;
import opennlp.tools.postag.POSTaggerME;
import opennlp.tools.postag.WordTagSampleStream;
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

/**
 * Created by alexanderweiss on 20.03.17.
 * Class for creating POS tags
 */
public class POSTagger {

    private POSModel posModel;
    private POSTaggerME tagger;


    /**
     * Default constructor, load or train model manually
     */
    public POSTagger(){
    }

    /**
     * Constructor which automatically loads a model from file
     * @param posModelFile
     */
    public POSTagger(String posModelFile){
        this.loadPOSModelFromFile(posModelFile);
    }

    /**
     * Train a model from a file and have the option to save it to models directory for later usage
     * @param trainingDataFileName
     */
    public void trainModel(String trainingDataFileName, boolean save) {

        InputStream dataIn = null;
        try {
            InputStreamFactory inputStreamFactory = () -> new FileInputStream(trainingDataFileName);
            ObjectStream<String> lineStream = new PlainTextByLineStream(inputStreamFactory,  Charset.forName("UTF-8"));
            ObjectStream<POSSample> sampleStream = new WordTagSampleStream(lineStream);

            this.posModel = POSTaggerME.train("en", sampleStream, TrainingParameters.defaultParams(), null);
            if(save) {
                FileUtils.writeModelToFile(this.posModel, "./models/" + FilenameUtils.getBaseName(trainingDataFileName).toString() + "Model.bin");
            }
        }
        catch (IOException e) {
            // Failed to read or parse training data, training failed
            e.printStackTrace();
        }
        finally {
            if (dataIn != null) {
                try {
                    dataIn.close();
                }
                catch (IOException e) {
                    // Not an issue, training already finished.
                    // The exception should be logged and investigated
                    // if part of a production system.
                    e.printStackTrace();
                }
            }
        }

    }

    /**
     * Load the POS model from a file
     * @param posModelFile
     */
    public void loadPOSModelFromFile(String posModelFile){
        InputStream modelIn = null;

        try {
            modelIn = new FileInputStream(posModelFile);
            this.posModel = new POSModel(modelIn);
            this.tagger = new POSTaggerME(this.posModel);
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

    public String [] tagSentence (String [] sentenceTokens){
        return tagger.tag(sentenceTokens);
    }
}
