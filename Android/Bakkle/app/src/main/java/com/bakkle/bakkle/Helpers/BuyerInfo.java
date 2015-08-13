package com.bakkle.bakkle.Helpers;

/**
 * Created by vanshgandhi on 7/30/15.
 */
public class BuyerInfo {

    private String name, FacebookURL;
    private int chatPk;

    public BuyerInfo(String name, String FacebookURL, int chatPk){
        this.name = name;
        this.FacebookURL = FacebookURL;
        this.chatPk = chatPk;
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

    public int getChatPk()
    {
        return chatPk;
    }

    public void setChatPk(int chatPk)
    {
        this.chatPk = chatPk;
    }


}
