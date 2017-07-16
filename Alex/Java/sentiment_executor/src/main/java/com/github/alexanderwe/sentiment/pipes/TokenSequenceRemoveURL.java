package com.github.alexanderwe.sentiment.pipes;

import cc.mallet.pipe.Pipe;
import cc.mallet.types.FeatureSequenceWithBigrams;
import cc.mallet.types.Instance;
import cc.mallet.types.Token;
import cc.mallet.types.TokenSequence;
import org.apache.log4j.Logger;

/**
 * Created by alexanderweiss on 16.07.17.
 */
public class TokenSequenceRemoveURL extends Pipe {

    boolean markDeletions = false;
    private static final Logger log = Logger.getLogger(TokenSequenceRemoveURL.class);


    public Instance pipe (Instance carrier) {

        if (carrier.getData() instanceof TokenSequence) {
            TokenSequence data = (TokenSequence) carrier.getData();
            carrier.setData(removeUrlFromTokenSequence(data));
        }
        else {
            throw new IllegalArgumentException("CharSequenceLowercase expects a CharSequence, found a " + carrier.getData().getClass());
        }

        return carrier;
    }


    private TokenSequence removeUrlFromTokenSequence(TokenSequence ts) {
        String regex = "(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";

        TokenSequence ret = new TokenSequence ();
        Token prevToken = null;
        for (int i = 0; i < ts.size(); i++) {
            Token t = ts.get(i);
            if (! t.getText().matches(regex)) { // if the token is not a url add it to the sequence
                ret.add (t);
                prevToken = t;
            } else if (markDeletions && prevToken != null)
                prevToken.setProperty (FeatureSequenceWithBigrams.deletionMark, t.getText());
        }
        return ret;
    }




}
