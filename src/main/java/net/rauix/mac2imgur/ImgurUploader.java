package net.rauix.mac2imgur;

import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.async.Callback;
import com.mashape.unirest.http.exceptions.UnirestException;
import org.apache.commons.codec.binary.Base64;
import org.json.JSONException;
import org.json.JSONObject;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import static net.rauix.mac2imgur.Main.logger;
import static net.rauix.mac2imgur.Main.prefs;
import static net.rauix.mac2imgur.Notifier.Notification;
import static net.rauix.mac2imgur.Notifier.sendNotification;
import static net.rauix.mac2imgur.Tray.Status;
import static net.rauix.mac2imgur.Tray.setTrayIcon;

public class ImgurUploader {

    static void upload(final File f) {

        // Set tray icon to active to show that some activity is taking place!
        setTrayIcon(Status.ACTIVE);

        final long startTime = System.currentTimeMillis();

        Unirest.post("https://api.imgur.com/3/upload")
                .header("Authorization", "Client-ID 5867856c9027819")
                .field("image", getEncodedImage(f))
                .field("type", "base64")
                .field("title", f.getName().replace(".png", ""))
                .field("description", "Uploaded by mac2imgur! (https://github.com/rauix/mac2imgur)")
                .asJsonAsync(new Callback<JsonNode>() {

                    public void failed(UnirestException e) {
                        sendNotification(Notification.FAILURE);
                        logger.warning(e);
                    }

                    public void cancelled() {
                    }

                    public void completed(HttpResponse<JsonNode> response) {
                        if (response.getCode() == 200) {
                            try {
                                JSONObject json = response.getBody().getObject();
                                logger.debug(response.getBody().toString());
                                // Check whether the user wants the gallery or direct link
                                String url = prefs.getBoolean("DIRECT-LINK", true) ? json.getJSONObject("data").getString("link") : "https://imgur.com/" + json.getJSONObject("data").getString("id");

                                // Check if the user wants the image automatically opened
                                if (prefs.getBoolean("OPEN-IMAGE", false)) {
                                    Utils.openBrowser(url);
                                }

                                // Copy url to clipboard
                                Utils.copyToClipboard(url);

                                // Notify user
                                sendNotification(Notification.SUCCESS);
                                long stopTime = System.currentTimeMillis();
                                long elapsedTime = stopTime - startTime;
                                System.out.println(elapsedTime);

                            } catch (JSONException e) {
                                sendNotification(Notification.FAILURE);
                                logger.warning(e);
                            } finally {
                                // Tidy up the file
                                Utils.tidyUp(f);
                                setTrayIcon(Status.INACTIVE);
                            }
                        } else {
                            logger.debug(response.getBody().toString());
                            setTrayIcon(Status.INACTIVE);
                            sendNotification(Notification.FAILURE);
                        }
                    }

                });
    }

    static String getEncodedImage(File f) {
        try {
            BufferedImage image = ImageIO.read(f);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "png", baos);
            return new Base64().encodeAsString(baos.toByteArray());
        } catch (IOException e) {
            logger.debug(e);
            return null;
        }
    }
}
