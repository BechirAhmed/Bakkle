/**
 * AndTinder v0.1 for Android
 *
 * @Author: Enrique López Mañas <eenriquelopez@gmail.com>
 * http://www.lopez-manas.com
 * <p/>
 * TAndTinder is a native library for Android that provide a
 * Tinder card like effect. A card can be constructed using an
 * image and displayed with animation effects, dismiss-to-like
 * and dismiss-to-unlike, and use different sorting mechanisms.
 * <p/>
 * AndTinder is compatible with API Level 13 and upwards
 * @copyright: Enrique López Mañas
 * @license: Apache License 2.0
 */

package com.andtinder.model;

import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;

import java.util.ArrayList;

public class CardModel
{

    private String title;
    private String seller;
    private String price;
    private String distance;
    private String method;
    private String pk;
    private String sellerImageURL;
    private String description;
    private ArrayList<String> imageURLs;

    private Drawable cardImageDrawable;


    public void setSellerImageDrawable(Drawable sellerImageDrawable)
    {
        this.sellerImageDrawable = sellerImageDrawable;
    }

    private Drawable sellerImageDrawable;
    private Drawable cardLikeImageDrawable;
    private Drawable cardDislikeImageDrawable;

    public Bitmap sellerImageBitmap;
    public Bitmap cardImageBitmap;

    private OnCardDismissedListener mOnCardDismissedListener = null;

    private OnClickListener mOnClickListener = null;

    public interface OnCardDismissedListener
    {
        void onLike(CardModel cardModel);

        void onDislike(CardModel cardModel);

        void onUp(CardModel cardModel);

        void onDown(CardModel cardModel);
    }

    public interface OnClickListener
    {
        void OnClickListener(CardModel cardModel);
    }

    public CardModel()
    {
        this(null, null, null, null, null, null, null, null, null/*, (Drawable)null, (Drawable)null*/);
    }

    public CardModel(String title, String seller, String price, String distance, String method,
                     String pk, String description, ArrayList imageURLs, String sellerImageURL
                     /*, Drawable cardImage, Drawable sellerImage*/)
    {
        this.title = title;
        this.seller = seller;
        this.price = price;
        this.distance = distance;
        this.method = method;
        this.pk = pk;
        this.imageURLs = imageURLs;
        this.sellerImageURL = sellerImageURL;
        this.description = description;
//		this.cardImageDrawable = cardImage;
//		this.sellerImageDrawable = sellerImage;
//		this.sellerImageBitmap = ((BitmapDrawable) sellerImageDrawable).getBitmap();
//		this.cardImageBitmap = ((BitmapDrawable) cardImageDrawable).getBitmap();
    }

	/*public CardModel(String title, String seller, String price, String distance, String method, String pk, String cardImageURL, Bitmap cardImage, Bitmap sellerImage) {
		this.title = title;
		this.seller = seller;
		this.price = price;
		this.distance = distance;
		this.method = method;
		this.pk = pk;
		this.cardImageURL = cardImageURL;
//		this.cardImageDrawable = new BitmapDrawable(null, cardImage);
//		this.sellerImageDrawable = new BitmapDrawable(null, sellerImage);
//		this.sellerImageBitmap = sellerImage;
//		this.cardImageBitmap = cardImage;
	}*/


    public String getTitle()
    {
        return title;
    }

    public void setTitle(String title)
    {
        this.title = title;
    }

    public String getSeller()
    {
        return seller;
    }

    public void setSeller(String seller)
    {
        this.seller = seller;
    }

    public String getPrice()
    {
        return price;
    }

    public void setPrice(String price)
    {
        this.price = price;
    }

    public String getDistance()
    {
        return distance;
    }

    public void setDistance(String distance)
    {
        this.distance = distance;
    }

    public String getMethod()
    {
        return method;
    }

    public void setMethod(String method)
    {
        this.method = method;
    }

    public Drawable getSellerImageDrawable()
    {
        return sellerImageDrawable;
    }

    public Drawable getCardImageDrawable()
    {
        return cardImageDrawable;
    }

    public String getPk()
    {
        return pk;
    }

    public void setPk(String pk)
    {
        this.pk = pk;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public ArrayList<String> getImageURLs()
    {
        return imageURLs;
    }

    public void setImageURLs(ArrayList<String> imageURLs)
    {
        this.imageURLs = imageURLs;
    }

    public String getCardImageURL()
    {
        return imageURLs.get(0);
    }

    public String getSellerImageURL()
    {
        return sellerImageURL;
    }

    public void setSellerImageURL(String sellerImageURL)
    {
        this.sellerImageURL = sellerImageURL;
    }

    public void setCardImageDrawable(Drawable cardImageDrawable)
    {
        this.cardImageDrawable = cardImageDrawable;
    }

    public Drawable getCardLikeImageDrawable()
    {
        return cardLikeImageDrawable;
    }

    public void setCardLikeImageDrawable(Drawable cardLikeImageDrawable)
    {
        this.cardLikeImageDrawable = cardLikeImageDrawable;
    }

    public Drawable getCardDislikeImageDrawable()
    {
        return cardDislikeImageDrawable;
    }

    public void setCardDislikeImageDrawable(Drawable cardDislikeImageDrawable)
    {
        this.cardDislikeImageDrawable = cardDislikeImageDrawable;
    }

    public void setOnCardDismissedListener(OnCardDismissedListener listener)
    {
        this.mOnCardDismissedListener = listener;
    }

    public OnCardDismissedListener getOnCardDismissedListener()
    {
        return this.mOnCardDismissedListener;
    }


    public void setOnClickListener(OnClickListener listener)
    {
        this.mOnClickListener = listener;
    }

    public OnClickListener getOnClickListener()
    {
        return this.mOnClickListener;
    }

}
