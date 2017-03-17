
import org.json.simple.JSONArray;
import utils.LanguageUtil;

import java.io.IOException;


/**
 * Created by alexanderweiss on 02.03.17.
 */
public class Test {




    public static void main (String [] args) {

        FacebookMonitor facebookMonitor = new FacebookMonitor("EAACEdEose0cBAA5v4VJFKt8YQ8bYk8G1QLirlyorEQ4bM94foPhkXZCUenirseFURfB2k7jlKDb71LQ4AIqWfLgFSSLbyFLxbZAc8oqIZCvcu3G44DQ6sUNfU4G6ePorUOZBuXvlJGz6SW1aMATgInJRwS2E0182kFjvTHgx9unVy1peVR8iWSJP2cYI8HoZD");
        try {

            JSONArray humiraJSON = facebookMonitor.searchPagesData("Humira");
            JSONArray adalimumabJSON = facebookMonitor.searchPagesData("Adalimumab");
            JSONArray enbrelJSON = facebookMonitor.searchPagesData("Enbrel");
            JSONArray trilipixJSON = facebookMonitor.searchPagesData("Trilipix");
            JSONArray imbruvicaJSON = facebookMonitor.searchPagesData("Imbruvica");


            facebookMonitor.writeJSONToFile(humiraJSON.toJSONString(), "humiraPages");
            facebookMonitor.writeJSONToFile(adalimumabJSON.toJSONString(), "adalimumabPages");
            facebookMonitor.writeJSONToFile(enbrelJSON.toJSONString(), "enbrelPages");
            facebookMonitor.writeJSONToFile(trilipixJSON.toJSONString(), "trilipixPages");
            facebookMonitor.writeJSONToFile(imbruvicaJSON.toJSONString(), "imbruvicaPages");


            facebookMonitor.writeJSONtoCSV(humiraJSON.toJSONString(), "humiraPages");
            facebookMonitor.writeJSONtoCSV(adalimumabJSON.toJSONString(), "adalimumabPages");
            facebookMonitor.writeJSONtoCSV(enbrelJSON.toJSONString(), "enbrelPages");
            facebookMonitor.writeJSONtoCSV(trilipixJSON.toJSONString(), "trilipixPages");
            facebookMonitor.writeJSONtoCSV(imbruvicaJSON.toJSONString(), "imbruvicaPages");
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
