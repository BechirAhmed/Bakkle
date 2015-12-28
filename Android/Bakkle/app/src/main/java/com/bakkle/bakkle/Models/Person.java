package com.bakkle.bakkle.Models;

import java.io.Serializable;

/**
 * Created by vanshgandhi on 12/5/15.
 */
public class Person implements Serializable
{
    String avatar_image_url;
    String display_name;
    String description;
    String facebook_id;
    int pk;
    int flavor;
    String user_location;

    public Person()
    {

    }

    public String getAvatar_image_url()
    {
        return avatar_image_url;
    }

    public void setAvatar_image_url(String avatar_image_url)
    {
        this.avatar_image_url = avatar_image_url;
    }

    public String getDisplay_name()
    {
        return display_name;
    }

    public void setDisplay_name(String display_name)
    {
        this.display_name = display_name;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public String getFacebook_id()
    {
        return facebook_id;
    }

    public void setFacebook_id(String facebook_id)
    {
        this.facebook_id = facebook_id;
    }

    public int getPk()
    {
        return pk;
    }

    public void setPk(int pk)
    {
        this.pk = pk;
    }

    public int getFlavor()
    {
        return flavor;
    }

    public void setFlavor(int flavor)
    {
        this.flavor = flavor;
    }

    public String getUser_location()
    {
        return user_location;
    }

    public void setUser_location(String user_location)
    {
        this.user_location = user_location;
    }
}