package net.rauix.mac2imgur;

import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.exceptions.UnirestException;
import org.json.JSONObject;

import java.io.IOException;

public class AccountUpload implements ImgurUpload {

    private Image img;
    private HttpResponse<JsonNode> response;

    public AccountUpload(Image img) {
        this.img = img;
    }

    public void start() throws UnirestException, IOException {

        String accessToken;
        boolean tokenValid = Utils.isTokenStillValid();

        if(!tokenValid || Utils.getLastToken() == null) {
            Authorize auth = new Authorize();
            auth.makeNewAccessTokenRequest();
            if(auth.wasSuccessful())
                accessToken = auth.getAccessToken();
            else
                accessToken = Utils.getLastToken();


        } else
            accessToken = Utils.getLastToken();



        response = Unirest.post("https://api.imgur.com/3/upload")
                .header("Authorization", "Client-Bearer "+accessToken)
                .field("image", img.getEncodedImage())
                .field("type", "base64")
                .field("title", img.getName())
                .field("description", "Uploaded by mac2imgur! (https://github.com/dexafree/mac2imgur)")
                .asJson();

    }

    public boolean wasSuccessful() {
        return response.getCode() == 200;
    }

    public JSONObject getResponse() {
        return response.getBody().getObject();
    }

}

