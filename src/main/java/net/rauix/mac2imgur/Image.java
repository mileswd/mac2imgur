package net.rauix.mac2imgur;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.prefs.Preferences;

import static net.rauix.mac2imgur.Main.DIR;

public class Image {

    private File f;
    private String name;

    public Image(File f) {
        this.f = f;
        this.name = FilenameUtils.removeExtension(f.getName());
    }

    /**
     * Returns the Image name without the extension
     *
     * @return Image name as a String
     */
    public String getName() {
        return name;
    }

    /**
     * Encodes the Image to Base64 and returns it as a string
     *
     * @return Base64 encoded string representation of the Image
     * @throws IOException
     */
    public String getEncodedImage() throws IOException {
        BufferedImage image = ImageIO.read(f);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        String extension = FilenameUtils.getExtension(f.getName());

        if(extension.equalsIgnoreCase("JPEG")) extension = "jpg";

        ImageIO.write(image, extension, baos);
        return new Base64().encodeAsString(baos.toByteArray());
    }

    /**
     * Tidies up the image according to user preferences
     *
     * @param prefs The mac2imgur preferences
     * @throws IOException
     */
    public void tidyUp(Preferences prefs) throws IOException {
        /*
         * IGNORE = Do nothing
		 * MOVE = Move to Directory
		 * DELETE = Delete screenshot
		 */
        String moveDir = prefs.get("MOVE-DIR", DIR);
        if (prefs.get("TIDY", "IGNORE").equals("MOVE") && !moveDir.equals(DIR)) {
            Utils.getLogger().debug("Moving screenshot to " + moveDir);
            FileUtils.moveFileToDirectory(f, new File(moveDir), false);
        } else if (prefs.get("TIDY", "IGNORE").equals("DELETE")) {
            FileUtils.deleteQuietly(f);
        }
    }
}
