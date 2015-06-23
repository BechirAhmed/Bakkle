package com.bakkle.bakkle;

import com.google.gson.JsonObject;

/**
 * Created by vanshgandhi on 6/23/15.
 */
public class FeedItem {

    String status, description, price, postDate, title, buyerRating, sellerDisplayName, sellerLocation, sellerFacebookId, sellerPk, sellerRating, location, pk, method;
    String[] tags, imageUrls;
    JsonObject seller;

    public FeedItem(){

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

    public String[] getTags() {
        return tags;
    }

    public void setTags(String[] tags) {
        this.tags = tags;
    }

    public String[] getImageUrls() {
        return imageUrls;
    }

    public void setImageUrls(String[] imageUrls) {
        this.imageUrls = imageUrls;
    }

    public JsonObject getSeller() {
        return seller;
    }

    public void setSeller(JsonObject seller) {
        this.seller = seller;
    }

}
