package nlp.lemmatize;

import opennlp.tools.cmdline.CmdLineUtil;
import opennlp.tools.cmdline.TerminateToolException;
import opennlp.tools.lemmatizer.LemmaSampleStream;
import opennlp.tools.lemmatizer.LemmatizerFactory;
import opennlp.tools.lemmatizer.LemmatizerME;
import opennlp.tools.lemmatizer.LemmatizerModel;
import opennlp.tools.util.*;
import opennlp.tools.util.model.ModelUtil;
import org.apache.commons.io.FilenameUtils;
import utils.FileUtils;

import java.io.*;
import java.nio.charset.Charset;

/**
 * Created by alexanderweiss on 21.03.17.
 */
public class SimpleLemmatizer {


    private LemmatizerModel model;
    private LemmatizerME lemmatizer;


    /**
     * Default constructor, load or train model manually
     */
    public SimpleLemmatizer(){
    }

    /**
     * Constructor which automatically loads a model from file
     * @param lemmatizeModelFile
     */
    public SimpleLemmatizer(String lemmatizeModelFile){
        this.loadLemmatizeModelFromFile(lemmatizeModelFile);
    }

    /**
     * Train a model from a file and have the option to save it to models directory for later usage
     * @param trainingDataFileName
     */
    public void trainModel(String trainingParamFile, String trainingDataFileName, boolean save) {
        TrainingParameters mlParams = CmdLineUtil.loadTrainingParameters(trainingParamFile,false);

        InputStreamFactory inputStreamFactory = null;
        try {
            inputStreamFactory = new MarkableFileInputStreamFactory(
                    new File(trainingDataFileName));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        ObjectStream<String> lineStream = null;
        LemmaSampleStream lemmaStream = null;
        try {
            lineStream = new PlainTextByLineStream(
                    (inputStreamFactory), "UTF-8");
            lemmaStream = new LemmaSampleStream(lineStream);
        } catch (IOException e) {
            CmdLineUtil.handleCreateObjectStreamError(e);
        }

        try {
            this.model = LemmatizerME.train("en", lemmaStream, mlParams,
                    new LemmatizerFactory());

            if(save) {
                FileUtils.writeModelToFile(this.model, "./models/" + FilenameUtils.getBaseName(trainingDataFileName).toString() + "Model.bin");
            }

        } catch (IOException e) {
            throw new TerminateToolException(-1,
                    "IO error while reading training data or indexing data: "
                            + e.getMessage(),
                    e);
        }
    }


    /**
     * Load a category model from file
     * @param lemmatizeModelFile
     */
    public void loadLemmatizeModelFromFile(String lemmatizeModelFile){
        InputStream modelIn = null;
        try {
            modelIn = new FileInputStream(lemmatizeModelFile);
            this.model = new LemmatizerModel(modelIn);
            this.lemmatizer = new LemmatizerME(this.model);
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


    public String [] lemmatize (String [] tokens, String [] postags){
        String[] lemmas = lemmatizer.lemmatize(tokens, postags);
        String[] decodedLemmas = lemmatizer.decodeLemmas(tokens, lemmas);

        return decodedLemmas;
    }



}
