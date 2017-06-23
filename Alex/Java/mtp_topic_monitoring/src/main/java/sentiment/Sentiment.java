package sentiment;

import cc.mallet.classify.*;
import cc.mallet.classify.evaluate.ConfusionMatrix;
import cc.mallet.pipe.*;
import cc.mallet.pipe.iterator.CsvIterator;
import cc.mallet.types.CrossValidationIterator;
import cc.mallet.types.Instance;
import cc.mallet.types.InstanceList;
import cc.mallet.types.Labeling;
import cc.mallet.util.Randoms;
import org.apache.log4j.Logger;
import td.CharSequenceRemoveURL;
import td.TokenSequenceRemoveURL;


import java.io.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Pattern;

/**
 * Created by alexanderweiss on 25.04.17.
 */
public class Sentiment {

    private static final Logger log = Logger.getLogger(Sentiment.class);
    protected Pipe pipe;
    protected InstanceList trainInstances;

    Sentiment(){
        log.info("Getting sentiment class ready");
        pipe = buildPipe();
        log.info("Sentiment class initialized");
    }


    /**
     * Train a classifier with the training instance
     * @return Classifier
     */
    public Classifier trainClassifier(InstanceList trainInstances, SentimentClassifierType sentimentClassifierType){
        ClassifierTrainer trainer = null;
        switch (sentimentClassifierType){
            case NAIVE_BAYES: trainer = new NaiveBayesTrainer(); break;
            case SVM: break;
            default: break;
        }
            return trainer.train(trainInstances);
    }

    protected Pipe buildPipe() {
        ArrayList<Pipe>  pipeList = new ArrayList<Pipe> ();
        log.info("Building Pipe");
        pipeList.add(new Input2CharSequence("UTF-8"));
        Pattern patternToken = Pattern.compile("[\\p{L}\\p{N}_]+"); // every word is a token
        pipeList.add(new CharSequence2TokenSequence(patternToken));
        pipeList.add(new TokenSequenceLowercase());
        pipeList.add(new TokenSequenceRemoveStopwords(false, false));
        //pipeList.add(new TokenSequenceRemoveURL());
        pipeList.add(new TokenSequence2FeatureSequence());
        pipeList.add(new Target2Label());
        pipeList.add(new FeatureSequence2FeatureVector());
        return new SerialPipes(pipeList);
    }

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
                System.out.print(labeling.getLabelAtRank(rank) + ":" +
                        labeling.getValueAtRank(rank) + " ");
            }
            System.out.println();

        }
    }

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

    //TODO: Add stratified sampling to n fold cross validation
    public Trial testTrainSplit(InstanceList instances, SentimentClassifierType sentimentClassifierType) {

        int TRAINING = 0;
        int TESTING = 1;
        int VALIDATION = 2;

        // Split the input list into training (90%) and testing (10%) lists.
        // The division takes place by creating a copy of the list,
        //  randomly shuffling the copy, and then allocating
        //  instances to each sub-list based on the provided proportions.

        System.out.println(instances.targetLabelDistribution());

        InstanceList[] instanceLists =
                instances.split(new Randoms(),
                        new double[] {0.8, 0.2, 0.0});
        

        //  The third position is for the "validation" set,
        //  which is a set of instances not used directly
        //  for training, but available for determining
        //  when to stop training and for estimating optimal
        //  settings of nuisance parameters.
        //  Most Mallet ClassifierTrainers can not currently take advantage
        //  of validation sets.

        Classifier classifier = trainClassifier( instanceLists[TRAINING], sentimentClassifierType );
        return new Trial(classifier, instanceLists[TESTING]);
    }

    /**
     * Uses random subsampling
     * @param n
     * @param sentimentClassifierType
     * @return
     */
    public Trial randomCrossValidation(int n, SentimentClassifierType sentimentClassifierType){

        log.info("Using " + sentimentClassifierType.name()+  " for classification");
        Trial bestTrial = null;
        double bestF1 = 0.0;

        CrossValidationIterator crossValidationIterator = new CrossValidationIterator(this.trainInstances, n, new Randoms() );
        while(crossValidationIterator.hasNext()){
            InstanceList[] nextSplit = crossValidationIterator.nextSplit();
            InstanceList training = nextSplit[0];
            InstanceList testing = nextSplit[1];

            System.out.println(training.size());
            System.out.println(testing.size());

            Classifier classifier = trainClassifier( training, sentimentClassifierType );
            Trial crossFoldTrial = new Trial(classifier, testing);

            if (crossFoldTrial.getF1("negative") >  bestF1){
                bestF1 = crossFoldTrial.getF1("negative");
                bestTrial = crossFoldTrial;
            }
            
        }
        return bestTrial;
    }
    

    //http://permalink.gmane.org/gmane.comp.ai.mallet.devel/1163

    /**
     * Uses stratified sampling
     * @param r
     * @param data
     * @param numFolds
     * @param sentimentClassifierType
     * @return
     */
    public Trial stratifiedCrossValidation(Randoms r, InstanceList data, int numFolds, SentimentClassifierType sentimentClassifierType) {

        log.info("Using " + sentimentClassifierType.name()+  " for classification");
        Trial bestTrial = null;
        double bestF1 = 0.0;

        int numLabels = data.getTargetAlphabet().size();
        // stratify the original data
        InstanceList dataPerClass[] = new InstanceList[numLabels];
        for (int i = 0; i < dataPerClass.length; i++) dataPerClass[i] = data.cloneEmpty();

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
        int count = 0;
        while (cvIters[0].hasNext()) {
            System.out.println(count++);
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
            Trial crossFoldTrial = new Trial(classifier, testing);

            if (crossFoldTrial.getF1("negative") >  bestF1){
                bestF1 = crossFoldTrial.getF1("negative");
                bestTrial = crossFoldTrial;
            }
        }
        return bestTrial;
    }

    /**
     * Load a CLassifier from an serialized file
     * @param serializedFile
     * @return
     * @throws FileNotFoundException
     * @throws IOException
     * @throws ClassNotFoundException
     */
    public Classifier loadClassifier(File serializedFile) throws FileNotFoundException, IOException, ClassNotFoundException {

        Classifier classifier;
        ObjectInputStream ois =
                new ObjectInputStream (new FileInputStream(serializedFile));
        classifier = (Classifier) ois.readObject();
        ois.close();

        return classifier;
    }

    /**
     * Serialize a classifier and save it to a file
     * @param classifier
     * @param serializedFile
     * @throws IOException
     */
    public void saveClassifier(Classifier classifier, File serializedFile) throws IOException {
        ObjectOutputStream oos =
                new ObjectOutputStream(new FileOutputStream(serializedFile));
        oos.writeObject(classifier);
        oos.close();
    }

    public static void main (String [] args) throws IOException, ClassNotFoundException {
        Sentiment snt = new Sentiment();
        snt.importFile(new File("tweets_manual_sentiment_training.txt"));

        System.out.println();
        log.info("Evaluate classifier");
        System.out.println();


        System.out.println(snt.trainInstances.targetLabelDistribution());

        Trial stratifiedBestNB = snt.stratifiedCrossValidation(new Randoms(), snt.trainInstances, 10, SentimentClassifierType.NAIVE_BAYES);
        Trial randomBestNB = snt.randomCrossValidation(10, SentimentClassifierType.NAIVE_BAYES);

        System.out.println("STRATIFIED SAMPLING - 10 FOLDS");

        ConfusionMatrix stratifiedConfusionMatrix = new ConfusionMatrix(stratifiedBestNB);
        System.out.println(stratifiedConfusionMatrix.toString());
        System.out.println(stratifiedBestNB.getF1("positive"));
        System.out.println(stratifiedBestNB.getF1("neutral"));
        System.out.println(stratifiedBestNB.getF1("negative"));


        System.out.println("RANDOM SAMPLING - 10 FOLDS");

        ConfusionMatrix randomConfusionMatrix = new ConfusionMatrix(randomBestNB);
        System.out.println(randomConfusionMatrix.toString());
        System.out.println(randomBestNB.getF1("positive"));
        System.out.println(randomBestNB.getF1("neutral"));
        System.out.println(randomBestNB.getF1("negative"));


    }

}


