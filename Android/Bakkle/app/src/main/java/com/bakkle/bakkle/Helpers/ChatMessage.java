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


    String price;
    boolean sentByBuyer;
    boolean accepted;
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

    public ChatMessage(boolean sentByBuyer, boolean accepted, boolean rejected, String price)
    {
        this.sentByBuyer = sentByBuyer;
        this.price = price;
        this.accepted = accepted;
        this.rejected = rejected;
        offer = true;
    }

    public boolean isOffer()
    {
        return offer;
    }

    public boolean isSentByBuyer()
    {
        return sentByBuyer;
    }

    public boolean isTextOnly(){
        return accepted || rejected;
    }

    public boolean isAccepted()
    {
        return accepted;
    }

    public boolean isRejected()
    {
        return rejected;
    }

    public String getPrice()
    {
        return price;
    }
}
