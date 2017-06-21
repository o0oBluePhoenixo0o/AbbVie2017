package td;

import cc.mallet.pipe.Pipe;
import cc.mallet.types.Instance;

import java.io.Serializable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by alexanderweiss on 24.04.17.
 */
public class CharSequenceRemoveURL extends Pipe {

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
