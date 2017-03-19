package utils;

import com.github.opendevl.JFlat;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Created by alexanderweiss on 18.03.17.
 * Class containing some useful methods for reading and writing files
 */
public class FileUtils {


    public FileUtils(){
    }

    /**
     * Read JSON Object from a file
     * @param fileName
     * @return
     */
    public static JSONObject readJSONObject(String fileName){
        try {
            return new JSONObject(new String(Files.readAllBytes(Paths.get(fileName))));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Read a JSON Array from a file
     * @param fileName
     * @return
     */
    public static JSONArray readJSONArray(String fileName){
        try {
            return new JSONArray(new String(Files.readAllBytes(Paths.get(fileName))));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Concat an arbitrary amount of JSON arrays
     * @param arrs
     * @return
     */
    public static JSONArray concatJSONArrays(JSONArray... arrs)  {
        JSONArray result = new JSONArray();
        for (JSONArray arr : arrs) {
            for (int i = 0; i < arr.length(); i++) {
                result.put(arr.get(i));
            }
        }
        return result;
    }

    /**
     * Write a JSON string to a file
     * @param jsonString
     * @param fileName
     * @throws IOException
     */
    public static void writeJSONToFile(String jsonString ,String fileName) throws IOException{
        createDir("json");
        FileWriter file = null;
        try  {

            if (fileName.endsWith(".json")){
                file= new FileWriter("./json/"+fileName);
            } else{
                file= new FileWriter("./json/"+fileName+".json");
            }
            file.write(jsonString);
            System.out.println("Successfully Copied JSON String to File...");
        } catch (IOException ioe){
            ioe.printStackTrace();
        } finally {
            file.flush();
            file.close();
        }
    }

    /**
     * Convert JSON to CSV
     * @param jsonString
     * @param fileName
     * @throws IOException
     */
    public static void writeJSONtoCSV(String jsonString ,String fileName) throws IOException {
        JFlat flatMe = new JFlat(jsonString);
        //directly write the JSON document to CSV
        createDir("csv");
        flatMe.json2Sheet().write2csv("./csv/"+fileName+".csv", new Character(';'));
    }

    /**
     * Create a directory if not existing
     * @param directoryName
     */
    public static void createDir(String directoryName){
        Path path = Paths.get("./"+directoryName);
        if(!Files.exists(path)) {
            try {
                Files.createDirectories(path);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    public static String readFileFromResources(String fileName){
        String result = "";

        ClassLoader classLoader = FileUtils.class.getClassLoader();
        try {
            result = IOUtils.toString(classLoader.getResourceAsStream(fileName));
        } catch (IOException e) {
            e.printStackTrace();
        }
        return result;
    }

}
