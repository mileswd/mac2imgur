package net.rauix.mac2imgur;

public enum ImageType {

    JPG(),
    GIF(),
    PNG(),
    APNG(),
    TIFF(),
    BMP(),
    PDF(),
    XCF(),
    INVALID();

    public static ImageType getTypeByName(String s) {
        for (ImageType it : ImageType.values()) {

            // Some end in 'jpeg' whilst others end in 'jpg'
            if (it.name().equalsIgnoreCase("JPEG")) return JPG;
            if (it.name().equals(s.toUpperCase())) {
                return it;
            }
        }
        return INVALID;
    }

    public boolean isEnabled() {
        return Utils.getPrefs().getBoolean(this.name(), this.name().equals("PNG"));
    }

}
