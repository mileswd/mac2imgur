package net.rauix.mac2imgur;

import com.mashape.unirest.http.exceptions.UnirestException;
import org.json.JSONObject;

import java.io.IOException;

public interface ImgurUpload {

    /**
     * Starts the upload process for the image
     *
     * @throws com.mashape.unirest.http.exceptions.UnirestException
     * @throws java.io.IOException
     */
    public void start() throws UnirestException, IOException;

    /**
     * Checks the response status for the HTTP 'OK' code
     *
     * @return whether the upload was successful or not
     */
    public boolean wasSuccessful();

    /**
     * Gets the response JSONObject
     *
     * @return the JSONObject response from api.imgur.com
     */
    public JSONObject getResponse();


}
