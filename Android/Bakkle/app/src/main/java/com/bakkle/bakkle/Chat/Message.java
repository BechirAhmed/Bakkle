package com.bakkle.bakkle.Chat;

import android.util.Log;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class Message
{
    private String text;
    private String timestamp;
    boolean isUTC;
    boolean isSelf;

    public Message()
    {
    }

    public Message(String text, String timestamp, boolean isSelf, boolean isUTC)
    {
        this.text = text;
        this.timestamp = timestamp;
        this.isUTC = isUTC;
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
        Log.v("Message", timestamp);
        this.timestamp = timestamp;
    }

    public boolean isUTC()
    {
        return isUTC;
    }

    public void setUTC(boolean UTC)
    {
        isUTC = UTC;
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
            SimpleDateFormat sourceFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
            sourceFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date parsed = sourceFormat.parse(getTimestamp());

            TimeZone tz = TimeZone.getDefault();
            SimpleDateFormat destFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
            destFormat.setTimeZone(tz);
            destFormat.format(parsed);
            Calendar calendar = destFormat.getCalendar();
            String curTime;
            if (isUTC) {
                curTime = String.format("%02d:%02d", calendar.get(Calendar.HOUR),
                        calendar.get(Calendar.MINUTE));
            } else {
                curTime = String.format("%02d:%02d", Calendar.getInstance().get(Calendar.HOUR),
                        Calendar.getInstance().get(Calendar.MINUTE));
            }

            return calendar.getDisplayName(Calendar.MONTH, Calendar.SHORT, Locale.US) + " " +
                    calendar.get(Calendar.DAY_OF_MONTH) + ", " +
                    curTime + " " +
                    calendar.getDisplayName(Calendar.AM_PM, Calendar.SHORT, Locale.US);

        } catch (ParseException e) {
            e.printStackTrace();
            return "Jan 1, 12:00 AM";
        }
    }
}
