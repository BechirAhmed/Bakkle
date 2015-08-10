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


    public ChatMessage(boolean left, String message/*, String name, Date timestamp*/){
        this.left = left;
        right = !left;
        this.message = message;
        this.name = name;
        this.timestamp = timestamp;
    }
}
