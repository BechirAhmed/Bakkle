package com.bakkle.bakkle;

import android.app.Fragment;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.andtinder.model.CardModel;
import com.andtinder.model.Orientations;
import com.andtinder.view.CardContainer;
import com.andtinder.view.SimpleCardStackAdapter;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.koushikdutta.ion.Ion;

import java.util.ArrayList;

/**
 * A simple {@link Fragment} subclass.
 */
public class FeedFragment extends Fragment implements View.OnTouchListener {

    private ViewGroup mRrootLayout;
    private int _xDelta;
    private int _yDelta;

    ServerCalls serverCalls;

    Bitmap bitmap;

    JsonObject jsonResult;

    SharedPreferences.Editor editor;
    SharedPreferences preferences;


    public FeedFragment() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_feed, container, false);

        preferences = PreferenceManager.getDefaultSharedPreferences(getActivity().getApplicationContext());
        editor = preferences.edit();

        serverCalls = new ServerCalls(getActivity().getApplicationContext());
        editor.putBoolean("stillWorking", true);
        editor.apply();
        jsonResult = serverCalls.getFeedItems(
                preferences.getString("auth_token", "0"),
                "99999999",
                "100",
                "",
                "32,32",
                "",
                preferences.getString("uuid", "0")
        );

        CardContainer mCardContainer = (CardContainer) view.findViewById(R.id.cardView);
        mCardContainer.setOrientation(Orientations.Orientation.Ordered);

        if(jsonResult != null)
            populateFeed(jsonResult, mCardContainer);
        else
            Log.d("umm", "what");

        return view;
    }


    @Override
    public boolean onTouch(View v, MotionEvent event) {
        /*final int X = (int) event.getRawX();
        final int Y = (int) event.getRawY();
        switch (event.getAction() & MotionEvent.ACTION_MASK) {
            case MotionEvent.ACTION_DOWN:
                RelativeLayout.LayoutParams lParams = (RelativeLayout.LayoutParams) v.getLayoutParams();
                _xDelta = X - lParams.leftMargin;
                _yDelta = Y - lParams.topMargin;
                break;
            case MotionEvent.ACTION_UP:
                break;
            case MotionEvent.ACTION_POINTER_DOWN:
                break;
            case MotionEvent.ACTION_POINTER_UP:
                break;
            case MotionEvent.ACTION_MOVE:
                RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) v
                        .getLayoutParams();
                layoutParams.leftMargin = X - _xDelta;
                layoutParams.topMargin = Y - _yDelta;
//                layoutParams.rightMargin = -250;
//                layoutParams.bottomMargin = -250;
                v.setLayoutParams(layoutParams);
                break;
        }
        mRrootLayout.invalidate();*/
        return true;
    }

    public void populateFeed(JsonObject json, CardContainer mCardContainer)
    {

        JsonArray jsonArray = json.getAsJsonArray("feed");
        SimpleCardStackAdapter adapter = new SimpleCardStackAdapter(getActivity());
        JsonObject temp;
        ArrayList<FeedItem> feedItems = new ArrayList<FeedItem>();
        FeedItem feedItem = null;
        CardModel card;
        String status, description, price, postDate, title, buyerRating, sellerDisplayName, sellerLocation, sellerFacebookId, sellerPk, sellerRating, location, pk, method;
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray;



        for(JsonElement element : jsonArray)
        {
            feedItem = new FeedItem();
            temp = element.getAsJsonObject();

            feedItem.setTitle(temp.get("title").getAsString());
            feedItem.setDescription(temp.get("description").getAsString());
            feedItem.setSellerDisplayName(temp.get("seller").getAsJsonObject().get("display_name").getAsString());
            feedItem.setPrice(temp.get("price").getAsString());
            feedItem.setLocation(temp.get("location").getAsString()); //TODO: difference between location and sellerlocation??
            feedItem.setMethod(temp.get("method").getAsString());
            sellerFacebookId = temp.get("seller").getAsJsonObject().get("facebook_id").getAsString();


            imageUrlArray = temp.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<String>();
            for(JsonElement urlElement : imageUrlArray)
            {
                imageUrls.add(urlElement.getAsString());
            }
            feedItem.setImageUrls(imageUrls);

            card = new CardModel(feedItem.getTitle(), feedItem.getSellerDisplayName(), "$" + feedItem.getPrice(),
                    feedItem.getDistance(), feedItem.getMethod(), getCardImage(feedItem), getSellerImage(sellerFacebookId));

            card.setOnCardDismissedListener(new CardModel.OnCardDismissedListener() {
                @Override
                public void onLike() {

                }

                @Override
                public void onDislike() {
                }
            });

            card.setOnClickListener(new CardModel.OnClickListener() {
                @Override
                public void OnClickListener() {
                }
            });

            adapter.add(card);
            feedItem = null;
            temp = null;
            imageUrlArray = null;
            imageUrls = null;
            card = null;
        }
        mCardContainer.setAdapter(adapter);


    }

    public Bitmap getCardImage(FeedItem item)
    {
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
            bitmap = Ion.with(this)
                    .load(item.getImageUrls().get(0))
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

    public Bitmap getSellerImage(String id)
    {
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
            bitmap = Ion.with(this)
                    .load("http://graph.facebook.com/" + id + "/picture?type=square")
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
