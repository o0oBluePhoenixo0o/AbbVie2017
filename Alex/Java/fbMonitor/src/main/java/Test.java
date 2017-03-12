
import org.json.simple.JSONArray;

import java.io.IOException;


/**
 * Created by alexanderweiss on 02.03.17.
 */
public class Test {




    public static void main (String [] args) {

        FacebookMonitor facebookMonitor = new FacebookMonitor("EAACEdEose0cBAMLwO5FScBt9DKi7TNF4LwrUi2vF6QZC7VxyvTwAZAGUxdIXJ07jHKW75DwHoaey44gf1hQnpfPlyXGsxUuEMMAdt0MiBDTBP32c6DmGYpxNXI3yzMU3UwyIq4iVshqk3FOKn4yyQy7e8yGZAmcaOzFctZAbyYf8OIa1ZCb5R3XsbHu0NnJoZD");
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


            /*facebookMonitor.writeJSONtoCSV(humiraJSON.toJSONString(), "humiraPages");
            facebookMonitor.writeJSONtoCSV(adalimumabJSON.toJSONString(), "adalimumabPages");
            facebookMonitor.writeJSONtoCSV(enbrelJSON.toJSONString(), "enbrelPages");
            facebookMonitor.writeJSONtoCSV(trilipixJSON.toJSONString(), "trilipixPages");
            facebookMonitor.writeJSONtoCSV(imbruvicaJSON.toJSONString(), "imbruvicaPages");*/
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}
