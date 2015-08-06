package com.bakkle.bakkle.Helpers;

import android.content.Context;
import android.graphics.Bitmap;
import android.location.Location;
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
    String numWant, numHold, numMeh, numView;

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

    public String getNumWant() {
        return numWant;
    }

    public void setNumWant(String numWant) {
        this.numWant = numWant;
    }

    public String getNumHold() {
        return numHold;
    }

    public void setNumHold(String numHold) {
        this.numHold = numHold;
    }

    public String getNumMeh() {
        return numMeh;
    }

    public void setNumMeh(String numMeh) {
        this.numMeh = numMeh;
    }

    public String getNumView() {
        return numView;
    }

    public void setNumView(String numView) {
        this.numView = numView;
    }

    public String getDistance(String latitude, String longitude){
        //TODO: Use location services to figure out how far away item actually is
        Location location1 = new Location("user location");
        location1.setLatitude(Double.parseDouble(latitude));
        location1.setLongitude(Double.parseDouble(longitude));

        String[] latlong = location.split(",");

        Location location2 = new Location("item location");
        location2.setLatitude(Double.parseDouble(latlong[0]));
        location2.setLongitude(Double.parseDouble(latlong[1]));

        return String.valueOf(round(location1.distanceTo(location2) * 0.00062137)) + " miles";
    }

    private int round(double d){
        double dAbs = Math.abs(d);
        int i = (int) dAbs;
        double result = dAbs - (double) i;
        if(result<0.5){
            return d<0 ? -i : i;
        }else{
            return d<0 ? -(i+1) : i+1;
        }
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
            Log.d("testing error 22", e.getMessage());
        }
        //return bitmap[0];
        return bitmap;
    }

    public Bitmap getSellerImage(){
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
        Bitmap bitmap = null;
        try{
            bitmap = Ion.with(c)
                    .load("http://graph.facebook.com/" + getSellerFacebookId() + "/picture?width=142&height=142")
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

        /*Bitmap bitmap=null;
        final String nomimg = "https://graph.facebook.com/"+ getSellerFacebookId() +"/picture?width=142&height=142";
        URL imageURL = null;

        try {
            imageURL = new URL(nomimg);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }

        try {
            HttpURLConnection connection = (HttpURLConnection) imageURL.openConnection();
            connection.setDoInput(true);
            connection.setInstanceFollowRedirects(true);
            connection.connect();
            InputStream inputStream = connection.getInputStream();
            //img_value.openConnection().setInstanceFollowRedirects(true).getInputStream()
            bitmap = BitmapFactory.decodeStream(inputStream);

        } catch (IOException e) {

            e.printStackTrace();
        }
        return bitmap;*/

    }

}
