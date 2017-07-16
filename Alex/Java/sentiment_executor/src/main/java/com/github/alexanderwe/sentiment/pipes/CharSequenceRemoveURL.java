package com.github.alexanderwe.sentiment.pipes;

import cc.mallet.types.Instance;

/**
 * Created by alexanderweiss on 16.07.17.
 */
public class CharSequenceRemoveURL {
    public Instance pipe (Instance carrier) {

        if (carrier.getData() instanceof CharSequence) {
            CharSequence data = (CharSequence) carrier.getData();
            carrier.setData(removeUrl(data.toString()));
        }
        else {
            throw new IllegalArgumentException("CharSequenceLowercase expects a CharSequence, found a " + carrier.getData().getClass());
        }

        return carrier;
    }


    private String removeUrl(String commentstr) {
        String regex = "(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";
        return commentstr.replaceAll(regex, "");
    }
}
