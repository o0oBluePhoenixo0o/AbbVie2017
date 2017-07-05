package sentiment;

import cc.mallet.classify.Classifier;

import java.io.*;

/**
 * Created by alexanderweiss on 02.07.17.
 */
public class SentimentExecutor {

    public Classifier loadClassifier(File serializedFile) throws FileNotFoundException, IOException, ClassNotFoundException {

        Classifier classifier;
        ObjectInputStream ois =
                new ObjectInputStream (new FileInputStream(serializedFile));
        classifier = (Classifier) ois.readObject();
        ois.close();

        return classifier;
    }


    public static void main(String [] args ) throws IOException, ClassNotFoundException {
        SentimentExecutor sntEx = new SentimentExecutor();
        Classifier nb = sntEx.loadClassifier(new File("naivebayes.bin"));
        System.out.println(nb.classify(args[0]).getLabeling().getBestLabel());
    }
}
