package td;

import cc.mallet.classify.Classifier;
import cc.mallet.classify.Trial;
import cc.mallet.classify.evaluate.ConfusionMatrix;
import cc.mallet.types.InstanceList;

/**
 * Created by alexanderweiss on 26.06.17.
 */
public class ExtentedTrial extends Trial {

    Trial trial;

    public ExtentedTrial(Classifier c, InstanceList ilist) {
        super(c, ilist);
    }

    public double getMacroPrecision(){

        double sumPrecision = 0.0;

        for (int i = 0; i< super.getClassifier().getLabelAlphabet().size(); i++) {
            sumPrecision += super.getPrecision(super.getClassifier().getLabelAlphabet().lookupLabel(i));
        }
        return sumPrecision/super.getClassifier().getLabelAlphabet().size();
    }

    public double getMacroRecall(){

        double sumRecall = 0.0;

        for (int i = 0; i< super.getClassifier().getLabelAlphabet().size(); i++) {
            sumRecall += super.getRecall(super.getClassifier().getLabelAlphabet().lookupLabel(i));
        }
        return sumRecall/super.getClassifier().getLabelAlphabet().size();
    }

    public double getMacroF1(){

        double sumF1 = 0.0;

        for (int i = 0; i< super.getClassifier().getLabelAlphabet().size(); i++) {
            sumF1 += super.getF1(super.getClassifier().getLabelAlphabet().lookupLabel(i));
        }
        return sumF1/super.getClassifier().getLabelAlphabet().size();
    }

    public double getMCC(){
        return 0.0;
    }


}
