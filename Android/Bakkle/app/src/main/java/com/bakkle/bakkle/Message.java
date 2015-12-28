package com.bakkle.bakkle;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

public class Message
{
    private String text;
    private String timestamp;
    boolean isSelf;

    public Message()
    {

    }

    public Message(String text, String timestamp, boolean isSelf)
    {
        this.text = text;
        this.timestamp = timestamp;
        this.isSelf = isSelf;
    }

    public String getText()
    {
        return text;
    }

    public void setText(String text)
    {
        this.text = text;
    }

    public String getTimestamp()
    {
        return timestamp;
    }

    public void setTimestamp(String timestamp)
    {
        this.timestamp = timestamp;
    }

    public boolean isSelf()
    {
        return isSelf;
    }

    public void setSelf(boolean self)
    {
        isSelf = self;
    }

    public String getNiceTimestamp()
    {
        try {
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(
                    new SimpleDateFormat("yyyy-MM-dd hh:mm:ss", Locale.US).parse(getTimestamp()));
            return calendar.getDisplayName(Calendar.MONTH, Calendar.SHORT, Locale.US) + " " +
                    calendar.get(Calendar.DAY_OF_MONTH) + ", " +
                    calendar.get(Calendar.HOUR_OF_DAY) + ":" + calendar.get(Calendar.MINUTE) + " " +
                    calendar.getDisplayName(Calendar.AM_PM, Calendar.SHORT, Locale.US);

        } catch (ParseException e) {
            return "Error";
        }
    }
}
