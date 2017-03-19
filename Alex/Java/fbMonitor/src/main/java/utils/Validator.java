package utils;

import java.net.URL;

/**
 * Created by alexanderweiss on 19.03.17.
 */
public class Validator {

    public static boolean isValidURL(String urlString)
    {
        try
        {
            URL url = new URL(urlString);
            url.toURI();
            return true;
        } catch (Exception exception)
        {
            return false;
        }
    }

}
