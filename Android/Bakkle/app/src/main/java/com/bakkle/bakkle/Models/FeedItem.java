package com.bakkle.bakkle.Models;

import com.bakkle.bakkle.Models.Person;

import java.io.Serializable;

/**
 * Created by vanshgandhi on 12/5/15.
 */
public class FeedItem implements Serializable
{
    private String   status;
    private String   description;
    private String   price;
    private String[] image_urls;
    private String   post_date;
    private String   title;
    private Person   seller;
    private String   location;
    private String   method;
    private int      pk;
    private int      numViews;
    private int      numNope;
    private int      numWant;
    private int      numHolding;
    private int      numReport;
    private int      convosWithNewMessage;

    public FeedItem()
    {
        setSeller(new Person());
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public String getPrice()
    {
        return price;
    }

    public void setPrice(String price)
    {
        this.price = price;
    }

    public String[] getImage_urls()
    {
        return image_urls;
    }

    public void setImage_urls(String[] image_urls)
    {
        this.image_urls = image_urls;
    }

    public String getPost_date()
    {
        return post_date;
    }

    public void setPost_date(String post_date)
    {
        this.post_date = post_date;
    }

    public String getTitle()
    {
        return title;
    }

    public void setTitle(String title)
    {
        this.title = title;
    }

    public Person getSeller()
    {
        return seller;
    }

    public void setSeller(Person seller)
    {
        this.seller = seller;
    }

    public String getLocation()
    {
        return location;
    }

    public void setLocation(String location)
    {
        this.location = location;
    }

    public int getPk()
    {
        return pk;
    }

    public void setPk(int pk)
    {
        this.pk = pk;
    }

    public String getMethod()
    {
        return method;
    }

    public void setMethod(String method)
    {
        this.method = method;
    }

    public int getNumViews()
    {
        return numViews;
    }

    public void setNumViews(int numViews)
    {
        this.numViews = numViews;
    }

    public int getNumNope()
    {
        return numNope;
    }

    public void setNumNope(int numNope)
    {
        this.numNope = numNope;
    }

    public int getNumWant()
    {
        return numWant;
    }

    public void setNumWant(int numWant)
    {
        this.numWant = numWant;
    }

    public int getNumHolding()
    {
        return numHolding;
    }

    public void setNumHolding(int numHolding)
    {
        this.numHolding = numHolding;
    }

    public int getNumReport()
    {
        return numReport;
    }

    public void setNumReport(int numReport)
    {
        this.numReport = numReport;
    }

    public int getConvosWithNewMessage()
    {
        return convosWithNewMessage;
    }

    public void setConvosWithNewMessage(int convosWithNewMessage)
    {
        this.convosWithNewMessage = convosWithNewMessage;
    }
}
