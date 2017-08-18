package com.github.alexanderwe.sentiment.pipes;

import cc.mallet.types.Instance;

/**
 * @author alexanderweiss
 * @date 16.07.17.
 * Extends the mallet Pipe class to remove URLs from a CharSequence
 */
public class CharSequenceRemoveURL {


    /**
     * Pipe the instance through the removeUrlFromTokenSequence method
     * @see CharSequenceRemoveURL#removeUrl(String)
     * @param carrier The instance
     * @return Carrier where all URLs are removed from the CharSequence data
     */
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


    /**
     * Removes all URLs from a string
     * @param text The text to remove the URLs from
     * @return String where all URLs are removed
     */
    private String removeUrl(String text) {
        String regex = "(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";
        return text.replaceAll(regex, "");
    }
}
