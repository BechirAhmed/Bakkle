package com.bakkle.bakkle.Helpers;

import java.util.Date;

/**
 * Created by vanshgandhi on 7/31/15.
 */
public class ChatMessage {
    public boolean left;
    public boolean right;
    public String message;
    public String name;
    public Date timestamp;

    float price;
    boolean selfOffer;
    boolean rejected;

    boolean offer;


    public ChatMessage(boolean left, String message/*, String name, Date timestamp*/){
        this.left = left;
        right = !left;
        this.message = message;
        offer = false;

//        this.name = name;
//        this.timestamp = timestamp;
    }

    public ChatMessage(boolean selfOffer, boolean rejected, float price)
    {
        this.selfOffer = selfOffer;
        this.price = price;
        this.rejected = rejected;
        offer = true;
    }

    public boolean isOffer()
    {
        return offer;
    }

    public boolean isSelfOffer()
    {
        return selfOffer;
    }
}
