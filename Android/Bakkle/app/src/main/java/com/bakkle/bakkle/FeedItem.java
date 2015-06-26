package com.bakkle.bakkle;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;

import com.google.gson.JsonObject;
import com.koushikdutta.ion.Ion;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 6/23/15.
 */
public class FeedItem {

    String status, description, price, postDate, title, buyerRating, sellerDisplayName, sellerLocation, sellerFacebookId, sellerPk, sellerRating, location, pk, method;
    ArrayList<String> tags, imageUrls;
    JsonObject seller;
    Context c;

    public FeedItem(Context c){
        this.c =c;
    }

    public ArrayList<String> getTags() {
        return tags;
    }

    public String getTagsString(){
        String s = "";
        if(tags.size() > 0) {
            for (String tag : tags) {
                s += tag + ", ";
            }
            return s.substring(0, s.length() - 2);
        }
        return s;
    }

    public void setTags(ArrayList<String> tags) {
        this.tags = tags;
    }

    public ArrayList<String> getImageUrls() {
        return imageUrls;
    }

    public void setImageUrls(ArrayList<String> imageUrls) {
        this.imageUrls = imageUrls;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPrice() {
        return price;
    }

    public void setPrice(String price) {
        this.price = price;
    }

    public String getPostDate() {
        return postDate;
    }

    public void setPostDate(String postDate) {
        this.postDate = postDate;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBuyerRating() {
        return buyerRating;
    }

    public void setBuyerRating(String buyerRating) {
        this.buyerRating = buyerRating;
    }

    public String getSellerDisplayName() {
        return sellerDisplayName;
    }

    public void setSellerDisplayName(String sellerDisplayName) {
        this.sellerDisplayName = sellerDisplayName;
    }

    public String getSellerLocation() {
        return sellerLocation;
    }

    public void setSellerLocation(String sellerLocation) {
        this.sellerLocation = sellerLocation;
    }

    public String getSellerFacebookId() {
        return sellerFacebookId;
    }

    public void setSellerFacebookId(String sellerFacebookId) {
        this.sellerFacebookId = sellerFacebookId;
    }

    public String getSellerPk() {
        return sellerPk;
    }

    public void setSellerPk(String sellerPk) {
        this.sellerPk = sellerPk;
    }

    public String getSellerRating() {
        return sellerRating;
    }

    public void setSellerRating(String sellerRating) {
        this.sellerRating = sellerRating;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getPk() {
        return pk;
    }

    public void setPk(String pk) {
        this.pk = pk;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public JsonObject getSeller() {
        return seller;
    }

    public void setSeller(JsonObject seller) {
        this.seller = seller;
    }

    public String getDistance(){
        //TODO: Use location services to figure out how far away item actually is
        return "100 mi";
    }

    public Bitmap getFirstImage()
    {
        Bitmap bitmap = null;
        //final Bitmap[] bitmap = new Bitmap[1];
        /*Ion.with(this)
                .load(item.getImageUrls().get(0))
                .withBitmap()
                .asBitmap()
                .setCallback(new FutureCallback<Bitmap>() {
                    @Override
                    public void onCompleted(Exception e, Bitmap result) {
                        //bitmap[0] = result;
                        bitmap = result;
                    }
                });*/
        try{
            bitmap = Ion.with(c)
                    .load(getImageUrls().get(0))
                    .withBitmap()
                    .asBitmap()
                    .get();
        }
        catch (Exception e)
        {
            Log.d("testing error 11", e.getMessage());
        }
        //return bitmap[0];
        return bitmap;
    }

}
