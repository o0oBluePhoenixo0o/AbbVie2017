package com.github.alexanderwe.sentiment.trial;

import cc.mallet.classify.Classifier;
import cc.mallet.classify.Trial;
import cc.mallet.types.InstanceList;

/**
 * @author alexanderweiss
 * @date 16.07.17.
 * Extends the mallet Trial class with some evaluation values.
 */
public class ExtendedTrial extends Trial {

    public ExtendedTrial(Classifier c, InstanceList ilist) {
        super(c, ilist);
    }

    /**
     * Calculates the macro precision of the classifier
     *
     * @return The macro precision
     */
    public double getMacroPrecision() {

        double sumPrecision = 0.0;

        for (int i = 0; i < super.getClassifier().getLabelAlphabet().size(); i++) {
            sumPrecision += super.getPrecision(super.getClassifier().getLabelAlphabet().lookupLabel(i));
        }
        return sumPrecision / super.getClassifier().getLabelAlphabet().size();
    }

    /**
     * Calculates the macro recall of the classifier
     *
     * @return The macro recall
     */
    public double getMacroRecall() {

        double sumRecall = 0.0;

        for (int i = 0; i < super.getClassifier().getLabelAlphabet().size(); i++) {
            sumRecall += super.getRecall(super.getClassifier().getLabelAlphabet().lookupLabel(i));
        }
        return sumRecall / super.getClassifier().getLabelAlphabet().size();
    }

    /**
     * Calculates the macro F1 value of the classifier
     *
     * @return The macro recall
     */
    public double getMacroF1() {

        double sumF1 = 0.0;

        for (int i = 0; i < super.getClassifier().getLabelAlphabet().size(); i++) {
            sumF1 += super.getF1(super.getClassifier().getLabelAlphabet().lookupLabel(i));
        }
        return sumF1 / super.getClassifier().getLabelAlphabet().size();
    }
}