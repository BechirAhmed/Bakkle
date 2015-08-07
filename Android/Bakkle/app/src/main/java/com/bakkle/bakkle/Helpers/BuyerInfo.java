package com.bakkle.bakkle.Helpers;

/**
 * Created by vanshgandhi on 7/30/15.
 */
public class BuyerInfo {

    private String name, FacebookURL;

    public BuyerInfo(String name, String FacebookURL){
        this.name = name;
        this.FacebookURL = FacebookURL;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getFacebookURL() {
        return FacebookURL;
    }

    public void setFacebookURL(String facebookURL) {
        FacebookURL = facebookURL;
    }

}
