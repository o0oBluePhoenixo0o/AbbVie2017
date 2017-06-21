package sentiment;

import cc.mallet.classify.*;
import cc.mallet.pipe.*;
import cc.mallet.pipe.iterator.CsvIterator;
import cc.mallet.types.InstanceList;
import cc.mallet.types.Labeling;
import cc.mallet.util.Randoms;


import java.io.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Pattern;

/**
 * Created by alexanderweiss on 25.04.17.
 */
public class Sentiment {


    protected Pipe pipe;
    protected InstanceList trainInstances;

    Sentiment(){
        pipe = buildPipe();
    }


    /**
     * Train a classifier with a training instance list
     * @param trainingInstances
     * @return Classifier
     */
    public Classifier trainClassifier(InstanceList trainingInstances){

        ClassifierTrainer trainer = new NaiveBayesTrainer();
        return trainer.train(trainInstances);
    }

    /**
     * Load a CLassifier from an serialized file
     * @param serializedFile
     * @return
     * @throws FileNotFoundException
     * @throws IOException
     * @throws ClassNotFoundException
     */
    public Classifier loadClassifier(File serializedFile)
            throws FileNotFoundException, IOException, ClassNotFoundException {


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
    public void saveClassifier(Classifier classifier, File serializedFile)
            throws IOException {

        ObjectOutputStream oos =
                new ObjectOutputStream(new FileOutputStream(serializedFile));
        oos.writeObject(classifier);
        oos.close();
    }

    protected Pipe buildPipe() {
        ArrayList<Pipe> pipeList = new ArrayList<Pipe>();

        pipeList.add(new Input2CharSequence("UTF-8"));

        Pattern patternToken = Pattern.compile("[\\p{L}\\p{N}_]+");
        pipeList.add(new CharSequence2TokenSequence(patternToken));
        pipeList.add(new TokenSequenceLowercase());
        pipeList.add(new TokenSequenceRemoveStopwords(false, false));
//        pipeList.add(new TokenSequenceRemoveNonAlpha());
        pipeList.add(new TokenSequence2FeatureSequence());

        pipeList.add(new Target2Label());
        pipeList.add(new FeatureSequence2FeatureVector());

        return new SerialPipes(pipeList);
    }

    protected void importFile() {
        CsvIterator iter = null;
        try {
            trainInstances = new InstanceList(pipe);
            Reader fileReader = new InputStreamReader(new FileInputStream(new File("tweets_manual_sentiment_training.txt")), "UTF-8");
            trainInstances.addThruPipe(new CsvIterator (fileReader, Pattern.compile("^(\\S*)[\\s,]*(\\S*)[\\s,]*(.*)$"),
                    3, 2, 1)); // data, label, name fields
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

    public Trial testTrainSplit(InstanceList instances) {

        int TRAINING = 0;
        int TESTING = 1;
        int VALIDATION = 2;

        // Split the input list into training (90%) and testing (10%) lists.
        // The division takes place by creating a copy of the list,
        //  randomly shuffling the copy, and then allocating
        //  instances to each sub-list based on the provided proportions.

        InstanceList[] instanceLists =
                instances.split(new Randoms(),
                        new double[] {0.9, 0.1, 0.0});

        // The third position is for the "validation" set,
        //  which is a set of instances not used directly
        //  for training, but available for determining
        //  when to stop training and for estimating optimal
        //  settings of nuisance parameters.
        // Most Mallet ClassifierTrainers can not currently take advantage
        //  of validation sets.

        Classifier classifier = trainClassifier( instanceLists[TRAINING] );
        return new Trial(classifier, instanceLists[TESTING]);
    }


    public void crossValidate(int n, InstanceList instanceList){
        for (int i = 0 ; i<n; i++){
            System.out.println("We are in the " + i + "th  Fold");
            Trial crossFoldTrial = this.testTrainSplit(instanceList);

            System.out.println("Accuracy: " + crossFoldTrial.getAccuracy());

            // precision, recall, and F1 are calcuated for a specific
            //  class, which can be identified by an object (usually
            //  a String) or the integer ID of the class

            System.out.println("F1 for class 'very positive': " + crossFoldTrial.getF1("4"));
            System.out.println("F1 for class 'slightly positive': " + crossFoldTrial.getF1("3"));
            System.out.println("F1 for class 'neutral': " + crossFoldTrial.getF1("N"));
            System.out.println("F1 for class 'slightly negative': " + crossFoldTrial.getF1("2"));
            System.out.println("F1 for class 'very negative': " + crossFoldTrial.getF1("1"));

        }
    }



    public static void main (String [] args) throws IOException, ClassNotFoundException {
        System.out.println("Sentiment analysis\n\n\n");
        System.out.println("Reading data...");

        Sentiment snt = new Sentiment();
        snt.importFile();
        snt.crossValidate(10, snt.trainInstances);
        Classifier nbClassifier = snt.trainClassifier(null);
        System.out.println(nbClassifier.classify("I love you").getLabeling().getBestLabel());
        //Classifier nbClassifier = snt.loadClassifier(new File("naivebayes.bin"));
        snt.saveClassifier(nbClassifier, new File("naivebayes.bin"));

        snt.evaluate(nbClassifier, new File("tweets_sentiment.txt"));

    }

}


