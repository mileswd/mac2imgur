package net.rauix;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.Future;

import javax.imageio.ImageIO;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.output.ByteArrayOutputStream;
import org.json.JSONException;
import org.json.JSONObject;

import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.JsonNode;
import com.mashape.unirest.http.Unirest;
import com.mashape.unirest.http.async.Callback;

public class ImgurUploader {

	public static void upload(final File f){

		try {

			@SuppressWarnings("unused")
			Future<HttpResponse<JsonNode>> request = Unirest.post("https://api.imgur.com/3/upload")
			.header("Authorization", "Client-ID 5867856c9027819")
			.field("image", getEncodedImage(f))
			.field("type", "base64")
			.field("title", f.getName().replace(".png", ""))
			.field("description", "Uploaded by mac2imgur!")
			.asJsonAsync(new Callback<JsonNode>(){

				public void failed(Exception e){
					Notifier.uploadWasSuccessful(false);
					tidyUp(f);
				}

				public void completed(HttpResponse<JsonNode> response){

					try {
						InputStream raw = response.getRawBody();
						JSONObject output = response.getBody().getObject();
						String link = "https://imgur.com/" + output.getJSONObject("data").getString("id");
						String dlink = output.getJSONObject("data").getString("link");

						if (PreferencesHandler.prefs.getBoolean("directlink", true)){
							Utils.copyToClipboard(dlink);
						} else {
							Utils.copyToClipboard(link);
						}
						if (PreferencesHandler.prefs.getBoolean("openbrowser", false)){
							if (PreferencesHandler.prefs.getBoolean("directlink", true)){
								Utils.openBrowser(dlink);
							} else {
								Utils.openBrowser(link);
							}
						}
						Notifier.uploadWasSuccessful(true);
						raw.close();
					} catch (JSONException e){
						Notifier.uploadWasSuccessful(false);
					} catch (IOException e){
						e.printStackTrace();
					}
				}

				public void cancelled(){
					Notifier.uploadWasSuccessful(false);
				}
			});
		} catch (Exception e){
			Notifier.uploadWasSuccessful(false);
			e.printStackTrace();
		}
		tidyUp(f);
	}

	public static String getEncodedImage(File f) throws IOException {
		BufferedImage image = ImageIO.read(f);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ImageIO.write(image, "png", baos);
		byte[] byteimg = baos.toByteArray();
		return new String(new Base64().encodeAsString(byteimg));
	}

	public static void tidyUp(File f){
		String desktop = System.getProperty("user.home") + File.separator + "Desktop";
		if (PreferencesHandler.prefs.get("post-upload", "delete").equals("move")){
			System.out.println(PreferencesHandler.prefs.get("folderpath", desktop));
			if (PreferencesHandler.prefs.get("folderpath", desktop) != desktop){
				try {
					FileUtils.moveFileToDirectory(f, new File(PreferencesHandler.prefs.get("folderpath", desktop)), false);
					Utils.logger.info("Moving screenshot to " + PreferencesHandler.prefs.get("folderpath", desktop) + File.separator + f.getName());
				} catch (IOException e){
					e.printStackTrace();
				}
			}
		} else if (PreferencesHandler.prefs.get("post-upload", "delete").equals("delete")) {
			FileUtils.deleteQuietly(f);
		}
	}
}