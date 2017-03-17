package utils;


import com.cybozu.labs.langdetect.Detector;
import com.cybozu.labs.langdetect.DetectorFactory;
import com.cybozu.labs.langdetect.LangDetectException;
import com.cybozu.labs.langdetect.Language;
import org.apache.poi.util.IOUtils;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;


/**
 * Created by alexanderweiss on 15.03.17.
 */
public class LanguageUtil {

    private static final String[] defaultLanguages= new String[] { "af", "ar",
            "bg", "bn", "cs", "da", "de", "el", "en", "es", "et", "fa", "fi",
            "fr", "gu", "he", "hi", "hr", "hu", "id", "it", "ja", "kn", "ko",
            "lt", "lv", "mk", "ml", "mr", "ne", "nl", "no", "pa", "pl", "pt",
            "ro", "ru", "sk", "sl", "so", "sq", "sv", "sw", "ta", "te", "th",
            "tl", "tr", "uk", "ur", "vi", "zh-cn", "zh-tw" }; // Array to get all language codes from google langdetect jar


    public LanguageUtil(){
        this.init();
    }

    public void init(){
        List<String> languages = new ArrayList<>();

        for(String languageCode: defaultLanguages){
            try {
                languages.add(loadLanguageProfile(languageCode));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        try {
            DetectorFactory.loadProfile(languages);
        } catch (LangDetectException ex) {
            System.out.println("Could not load language profiles for google langdetect " + "\n"+  ex);
        }
    }
    public String detect(String text) {
        try {

            Detector detector = DetectorFactory.create();
            detector.append(text);
            System.out.println("Detected: " + detector.detect());
            return detector.detect();
        } catch (LangDetectException e) {
            e.printStackTrace();
        }
        return null;
    }
    public ArrayList<Language> detectLangs(String text) throws LangDetectException {
        Detector detector = DetectorFactory.create();
        detector.append(text);
        return detector.getProbabilities();
    }

    private static String loadLanguageProfile(String langCode) throws IOException {
        InputStream is=DetectorFactory.class.getClassLoader().getResourceAsStream("profiles/" + langCode);
        String profile=new String(IOUtils.toByteArray(is));
        is.close();
        return profile;
    }
}
