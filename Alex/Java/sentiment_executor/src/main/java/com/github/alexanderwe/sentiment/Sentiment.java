package com.github.alexanderwe.sentiment;

/**
 * Created by alexanderweiss on 16.07.17.
 */

import cc.mallet.classify.Classifier;
import cc.mallet.classify.ClassifierTrainer;
import cc.mallet.classify.NaiveBayesTrainer;
import cc.mallet.classify.Trial;
import cc.mallet.classify.evaluate.ConfusionMatrix;
import cc.mallet.pipe.*;
import cc.mallet.pipe.iterator.CsvIterator;
import cc.mallet.types.CrossValidationIterator;
import cc.mallet.types.Instance;
import cc.mallet.types.InstanceList;
import cc.mallet.types.Labeling;
import cc.mallet.util.Randoms;
import com.github.alexanderwe.sentiment.pipes.TokenSequenceRemoveURL;
import com.github.alexanderwe.sentiment.trial.ExtendedTrial;
import com.github.alexanderwe.sentiment.types.SentimentClassifierType;
import org.apache.log4j.Logger;

import java.io.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Pattern;

/**
 * @author alexanderweiss
 * @date 25.04.17
 * Main class of the application. It offers two different 'modes'. One for creating a model and training a classifier for sentiment
 * analysis. The second one is for loading a classifier and applying it to a dataset for detecting the sentiment of messages.
 */
public class Sentiment {

    private static final Logger log = Logger.getLogger(Sentiment.class);
    protected Pipe pipe;
    protected InstanceList trainInstances;

    Sentiment(){
        pipe = buildPipe();
    }


    /**
     * Train a classifier with the training instance
     * @param trainInstances The training instances used to train the classifier
     * @param sentimentClassifierType The classifier type
     * @return Classifier
     */
    public Classifier trainClassifier(InstanceList trainInstances, SentimentClassifierType sentimentClassifierType){
        ClassifierTrainer trainer = null;
        switch (sentimentClassifierType){
            case NAIVE_BAYES: trainer = new NaiveBayesTrainer(); break;
            case SVM: break; // not implemented
            default: break;
        }
        return trainer.train(trainInstances);
    }

    /**
     * Build a pipe for preprossessing the data
     * @return Pipe
     */
    protected Pipe buildPipe() {
        ArrayList<Pipe> pipeList = new ArrayList<Pipe> ();
        pipeList.add(new Input2CharSequence("UTF-8"));
        Pattern patternToken = Pattern.compile("[\\p{L}\\p{N}_]+"); // every word is a token
        pipeList.add(new CharSequence2TokenSequence(patternToken));
        pipeList.add(new TokenSequenceLowercase());
        pipeList.add(new TokenSequenceRemoveStopwords(false, false));
        pipeList.add(new TokenSequenceRemoveURL());
        pipeList.add(new TokenSequence2FeatureSequence());
        pipeList.add(new Target2Label());
        pipeList.add(new FeatureSequence2FeatureVector());
        return new SerialPipes(pipeList);
    }

    /**
     * Import a training file.
     * It has to fulfill this format: [name] [label] [data ... ]. The Whitespaces between the three types are mandatory.
     * @param file File which contains the training data
     */
    protected void importFile(File file) {
        log.info("Importing file : " + file.getAbsolutePath());
        CsvIterator iter = null;
        try {
            trainInstances = new InstanceList(pipe);
            Reader fileReader = new InputStreamReader(new FileInputStream(file), "UTF-8");
            trainInstances.addThruPipe(new CsvIterator (fileReader, Pattern.compile("^(\\S*)[\\s,]*(\\S*)[\\s,]*(.*)$"),
                    3, 2, 1)); // data, label, name fields
            log.info("File imported and training instances set");
        }catch (Exception e){
            e.printStackTrace();
        }
    }


    /**
     * Print out the labels from a classifier after classifying the instances from the file
     * @param classifier Pre built classifier object
     * @param file The file which contains the instances which need to be classified
     * @throws IOException Thrown if something fails while reading the file
     */
    public void printLabelings(Classifier classifier, File file) throws IOException {

        // Create a new iterator that will read raw instance data from
        //  the lines of a file.
        // Lines should be formatted as:
        //
        //   [name] [label] [data ... ]
        //
        //  in this case, "label" is ignored.

        CsvIterator reader =
                new CsvIterator(new FileReader(file),
                        "(\\w+)\\s+(\\w+)\\s+(.*)",
                        3, 2, 1);  // (data, label, name) field indices

        // Create an iterator that will pass each instance through
        //  the same pipe that was used to create the training data
        //  for the classifier.
        Iterator instances =
                classifier.getInstancePipe().newIteratorFrom(reader);

        // Classifier.classify() returns a Classification object
        //  that includes the instance, the classifier, and the
        //  classification results (the labeling). Here we only
        //  care about the Labeling.
        while (instances.hasNext()) {
            Labeling labeling = classifier.classify(instances.next()).getLabeling();

            // print the labels with their weights in descending order (ie best first)

            for (int rank = 0; rank < labeling.numLocations(); rank++){
               log.info(labeling.getLabelAtRank(rank) + ":" +
                        labeling.getValueAtRank(rank) + " ");
            }
        }
    }


    /**
     * Evaluate a classifier
     * @param classifier The classifier to evaluate
     * @param file The file with the data for evaluating the classifier
     * @throws IOException Thrown if something fails while reading the file
     */
    public void evaluate(Classifier classifier, File file) throws IOException {

        // Create an InstanceList that will contain the test data.
        // In order to ensure compatibility, process instances
        //  with the pipe used to process the original training
        //  instances.

        InstanceList testInstances = new InstanceList(classifier.getInstancePipe());

        // Create a new iterator that will read raw instance data from
        //  the lines of a file.
        // Lines should be formatted as:
        //
        //   [name] [label] [data ... ]

        CsvIterator reader =
                new CsvIterator(new FileReader(file),
                        "(\\w+)\\s+(\\w+)\\s+(.*)",
                        3, 2, 1);  // (data, label, name) field indices

        // Add all instances loaded by the iterator to
        //  our instance list, passing the raw input data
        //  through the classifier's original input pipe.

        testInstances.addThruPipe(reader);

        Trial trial = new Trial(classifier, testInstances);

        // The Trial class implements many standard evaluation
        //  metrics. See the JavaDoc API for more details.

        System.out.println("Accuracy: " + trial.getAccuracy());

        // precision, recall, and F1 are calcuated for a specific
        //  class, which can be identified by an object (usually
        //  a String) or the integer ID of the class

        System.out.println("F1 for class 'very positive': " + trial.getF1("4"));
        System.out.println("F1 for class 'very negative': " + trial.getF1("1"));

        System.out.println("Precision for class '" +
                classifier.getLabelAlphabet().lookupLabel(1) + "': " +
                trial.getPrecision(1));
    }


    /**
     * Splits the instance list into 80% testing and 20% training.
     * @param instances Instances which are used to traid and test the classifier
     * @param sentimentClassifierType Defines what classier type to use
     * @return Trial A trial to look up the evaluation results
     */
    public Trial testTrainSplit(InstanceList instances, SentimentClassifierType sentimentClassifierType) {

        int TRAINING = 0;
        int TESTING = 1;

        // Split the input list into training (80%) and testing (20%) lists.
        // The division takes place by creating a copy of the list,
        // randomly shuffling the copy, and then allocating
        // instances to each sub-list based on the provided proportions.

        System.out.println(instances.targetLabelDistribution());

        InstanceList[] instanceLists =
                instances.split(new Randoms(),
                        new double[] {0.8, 0.2, 0.0});

        Classifier classifier = trainClassifier( instanceLists[TRAINING], sentimentClassifierType );
        return new Trial(classifier, instanceLists[TESTING]);
    }

    /**
     * Uses random subsampling to get the best classifier based on the F1 measure
     * @param n
     * @param sentimentClassifierType Defines what classier type to use
     * @return ExtendedTrial to look up the evaluation results
     */
    public ExtendedTrial randomCrossValidation(int n, SentimentClassifierType sentimentClassifierType){

        log.info("Using " + sentimentClassifierType.name()+  " for classification");
        ExtendedTrial bestTrial = null;
        double bestF1 = 0.0;

        CrossValidationIterator crossValidationIterator = new CrossValidationIterator(this.trainInstances, n, new Randoms() );
        while(crossValidationIterator.hasNext()){
            InstanceList[] nextSplit = crossValidationIterator.nextSplit();
            InstanceList training = nextSplit[0];
            InstanceList testing = nextSplit[1];

            System.out.println(training.size());
            System.out.println(testing.size());

            Classifier classifier = trainClassifier( training, sentimentClassifierType );
            ExtendedTrial crossFoldTrial = new ExtendedTrial(classifier, testing);

            if (crossFoldTrial.getF1("negative") >  bestF1){
                bestF1 = crossFoldTrial.getF1("negative");
                bestTrial = crossFoldTrial;
            }

        }
        return bestTrial;
    }



    /**
     * Uses stratified sampling, to get the best classifier after the training phase
     * @param r Random variables
     * @param data Instance list with data to use during the cross validation
     * @param numFolds Defines how many folds are executed
     * @param sentimentClassifierType Defines what classier type to use
     * @see http://permalink.gmane.org/gmane.comp.ai.mallet.devel/1163
     * @return ExtendedTrial to look up the evaluation results
     */
    public ExtendedTrial stratifiedCrossValidation(Randoms r, InstanceList data, int numFolds, SentimentClassifierType sentimentClassifierType) {

        log.info("Using " + sentimentClassifierType.name()+  " for classification");
        ExtendedTrial bestTrial = null;
        double bestF1 = 0.0;

        int numLabels = data.getTargetAlphabet().size();
        // stratify the original data
        InstanceList dataPerClass[] = new InstanceList[numLabels];
        for (int i = 0; i < dataPerClass.length; i++) {
            dataPerClass[i] = data.cloneEmpty();

        }


        // shuffle the data initially and split by class
        data.shuffle(r);
        for (int ii = 0; ii < data.size(); ii++) {
            Instance inst = data.get(ii);
            int li = ((Labeling) inst.getTarget()).getBestIndex();
            dataPerClass[li].add(inst);
        }


        // create cross-validation iterators per class
        InstanceList.CrossValidationIterator cvIters[] = new InstanceList.CrossValidationIterator[numLabels];
        for (int i = 0; i < dataPerClass.length; i++) {
            if (dataPerClass[i].size() == 0) {
                System.out.println("ERROR: No examples forlabel: " + i);
            }
            cvIters[i] = dataPerClass[i].crossValidationIterator(numFolds);
        }

        // iterate over folds
        while (cvIters[0].hasNext()) {
            InstanceList[][] foldsPerClass = new InstanceList[numLabels][2];
            for (int i = 0; i < numLabels; i++)
                foldsPerClass[i] =
                        cvIters[i].next();
            InstanceList training = data.cloneEmpty();
            InstanceList testing = data.cloneEmpty();
            for (int i = 0; i < numLabels; i++) {
                training.addAll(foldsPerClass[i][0]); // add training fold for class
                testing.addAll(foldsPerClass[i][1]); // add testing fold for class
            }

            Classifier classifier = trainClassifier( training, SentimentClassifierType.NAIVE_BAYES );
            ExtendedTrial crossFoldTrial = new ExtendedTrial(classifier, testing);

            //Check which classifier is the best, iterate over all labels, check average F1 for the whole matrix and then decide if the current classifier is better or not

            double f1sum = 0;
            for (int i = 0; i <classifier.getLabelAlphabet().size(); i++){
                f1sum = f1sum + (crossFoldTrial.getF1(classifier.getLabelAlphabet().lookupLabel(i)));
            }
            double avgF1 = f1sum/classifier.getLabelAlphabet().size();
            if (avgF1 >  bestF1){
                bestF1 = avgF1;
                bestTrial = crossFoldTrial;
            }
        }
        return bestTrial;
    }

    /**
     * Load a CLassifier from an serialized file
     * @param serializedFile The serialized model file
     * @return Classifier The loaded classifier
     * @throws IOException Thrown if something fails during reading the file
     * @throws ClassNotFoundException Thrown if the loaded classifier has not the right class
     */
    public Classifier loadClassifier(File serializedFile) throws IOException, ClassNotFoundException {

        Classifier classifier;
        ObjectInputStream ois =
                new ObjectInputStream (new FileInputStream(serializedFile));
        classifier = (Classifier) ois.readObject();
        ois.close();

        return classifier;
    }

    /**
     * Serialize a classifier and save it to a file
     * @param classifier The classifier object which needs to be saved
     * @param serializedFile The serialized model file which is used to save the model
     * @throws IOException Exception if something fails during saving the classifier to the file
     */
    public void saveClassifier(Classifier classifier, File serializedFile) throws IOException {
        ObjectOutputStream oos =
                new ObjectOutputStream(new FileOutputStream(serializedFile));
        oos.writeObject(classifier);
        oos.close();
    }

    public static void main (String [] args) throws IOException, ClassNotFoundException {

        Sentiment snt = new Sentiment();

        switch (args[0]){

            //Training mode which takes a training file args[1] as input
            case "1":

                //Import file
                snt.importFile(new File(args[1]));

                //Train and test classifier
                ExtendedTrial stratifiedBestNB = snt.stratifiedCrossValidation(new Randoms(), snt.trainInstances, 10, SentimentClassifierType.NAIVE_BAYES);


                log.info("Evaluate classifier");
                log.info("STRATIFIED SAMPLING - 10 FOLDS");

                ConfusionMatrix stratifiedConfusionMatrix = new ConfusionMatrix(stratifiedBestNB);
                log.info(stratifiedConfusionMatrix.toString());


                int index = 0;
                int numCorrect = 0;
                int numInstances = 0;
                int trueLabel, classLabel;

                for (int i = 0; i < stratifiedBestNB.size(); i++) {
                    trueLabel = stratifiedBestNB.get(i).getInstance().getLabeling().getBestIndex();
                    classLabel = stratifiedBestNB.get(i).getLabeling().getBestIndex();
                    if (classLabel == index) {
                        numInstances++;
                        if (trueLabel == index) {
                            numCorrect++;
                        }
                    }
                }

                for (int i = 0; i< stratifiedBestNB.getClassifier().getLabelAlphabet().size(); i++) {
                    System.out.println(stratifiedBestNB.getClassifier().getLabelAlphabet().lookupLabel(i).toString() + " - F1:" + stratifiedBestNB.getF1(stratifiedBestNB.getClassifier().getLabelAlphabet().lookupLabel(i)));
                    System.out.println(stratifiedBestNB.getClassifier().getLabelAlphabet().lookupLabel(i).toString() + " - Recall:" + stratifiedBestNB.getRecall(stratifiedBestNB.getClassifier().getLabelAlphabet().lookupLabel(i)));
                    System.out.println(stratifiedBestNB.getClassifier().getLabelAlphabet().lookupLabel(i).toString() + " - Precision:" + stratifiedBestNB.getPrecision(stratifiedBestNB.getClassifier().getLabelAlphabet().lookupLabel(i)));
                }

                //Display evaluation values
                log.info("TP: " + numCorrect);
                log.info("FN " + ( numInstances-numCorrect ));
                log.info("Macro Precision: " + stratifiedBestNB.getMacroPrecision());
                log.info("Macro Recall: " + stratifiedBestNB.getMacroRecall());
                log.info("Macro F1: " + stratifiedBestNB.getMacroF1());
                log.info("Accuracy " + stratifiedBestNB.getAccuracy());


                //Save the classifier for later usage
                snt.saveClassifier(stratifiedBestNB.getClassifier(), new File("naivebayes.bin"));

                log.info("Classifier saved");
                break;
            // Classifying mode: Loads a model args[1] and detects the sentiment of one message from the provided args[2]
            case "2":
                Classifier nb = snt.loadClassifier(new File(args[1]));
                System.out.println(nb.classify(args[2]).getLabeling().getBestLabel());
                break;
        }
    }
}


