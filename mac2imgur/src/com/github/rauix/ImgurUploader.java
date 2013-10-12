package com.github.rauix;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.Future;

import javax.imageio.ImageIO;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.output.ByteArrayOutputStream;
import org.json.JSONException;
import org.json.JSONObject;

import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.async.Callback;

public class ImgurUploader {

	public static void upload(final File f) {

		try {

			@SuppressWarnings("unused")
			Future<HttpResponse<JsonNode>> request = Unirest.post("https://api.imgur.com/3/upload")
			.header("Authorization", "Client-ID 5867856c9027819")
			.field("image", getEncodedImage(f))
			.field("type", "base64")
			.field("title", f.getName().replace(".png", ""))
			.field("description", "Uploaded by mac2imgur!")
			.asJsonAsync(new Callback<JsonNode>() {

				public void failed(Exception e) {
					Tray.uploadWasSuccessful(false);
					f.delete();
				}

				public void completed(HttpResponse<JsonNode> response) {
					try {
						InputStream rawBody = response.getRawBody();
						JSONObject output = response.getBody().getObject();
						String link = "https://imgur.com/" + output.getJSONObject("data").getString("id");
						String dlink = output.getJSONObject("data").getString("link");

						if (PreferencesManager.getPreferences().getBoolean("directlink", true)){
							Utils.copyToClipboard(dlink);
						} else {
							Utils.copyToClipboard(link);
						}
						Tray.uploadWasSuccessful(true);
						if (PreferencesManager.getPreferences().getBoolean("openbrowser", false)){
							if (PreferencesManager.getPreferences().getBoolean("directlink", true)){
								Utils.openBrowser(dlink);
							} else {
								Utils.openBrowser(link);
							}
						}
						tidyUp(f);
					} catch (JSONException e) {
						e.printStackTrace();
					}
				}

				public void cancelled() {
					Tray.uploadWasSuccessful(false);
					f.delete();
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void tidyUp(File f){
		String desktop = System.getProperty("user.home") + File.separator + "Desktop";
		if (PreferencesManager.getPreferences().get("post-upload", "delete").contains("move")){
			System.out.println(PreferencesManager.getPreferences().get("folderpath", desktop));
			if (PreferencesManager.getPreferences().get("folderpath", desktop) != desktop){
				f.renameTo(new File(PreferencesManager.getPreferences().get("folderpath", desktop) + File.separator + f.getName()));
				System.out.println("Moving screenshot to " + PreferencesManager.getPreferences().get("folderpath", desktop) + File.separator + f.getName());
			}
		} else {
			f.delete();
		}
	}

	public static String getEncodedImage(File f) throws IOException {
		BufferedImage image = ImageIO.read(f);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ImageIO.write(image, "png", baos);
		byte[] byteimg = baos.toByteArray();
		return new String(new Base64().encodeAsString(byteimg));
	}
}