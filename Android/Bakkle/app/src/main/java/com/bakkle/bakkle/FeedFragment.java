package com.bakkle.bakkle;


import android.app.Fragment;
import android.content.SharedPreferences;
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

import java.util.ArrayList;

/**
 * A simple {@link Fragment} subclass.
 */
public class FeedFragment extends Fragment implements View.OnTouchListener {

    private ViewGroup mRrootLayout;
    private int _xDelta;
    private int _yDelta;

    ServerCalls serverCalls;

    JsonObject Jsonresult;

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
        Jsonresult = serverCalls.getFeedItems(
                preferences.getString("auth_token", "0"),
                "99999999",
                "",
                "",
                "32,32",
                "",
                preferences.getString("uuid", "0")
        );

        CardContainer mCardContainer = (CardContainer) view.findViewById(R.id.cardView);
        mCardContainer.setOrientation(Orientations.Orientation.Ordered);
        populateFeed(Jsonresult, mCardContainer);

//        mRrootLayout = (ViewGroup) view;
//        addCard(view, nextItemImage());
//        StackImageView card;
//        card = (StackImageView) view.findViewById(R.id.card);
//        card.setOnTouchListener(this);
        return view;
    }

//    public void addCard(View view, int imageID) //where imageID is something like R.drawable.bakkle_icon
//    {
//        LinearLayout linearLayout = (LinearLayout) view.findViewById(R.id.feed);
//        StackImageView card = new StackImageView(this.getActivity());
//        card.setImageResource(imageID);
//        card.setLayoutParams(new LinearLayout.LayoutParams(
//                LinearLayout.LayoutParams.MATCH_PARENT,
//                LinearLayout.LayoutParams.MATCH_PARENT
//        ));
//
//        linearLayout.addView(card);
//
//    }
//
//    //TODO: make code to check to see if there even is a next image.
//    public int nextItemImage(){
//        return R.drawable.bakkle_icon;
//    }


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
        String[] tags, imageUrls;
        JsonObject seller;


        for(JsonElement element : jsonArray)
        {
            feedItem = new FeedItem();
            temp = element.getAsJsonObject();
            feedItem.setTitle(temp.get("title").getAsString());
            feedItem.setDescription(temp.get("description").getAsString());
            card = new CardModel(feedItem.getTitle(), feedItem.getDescription(), getActivity().getResources().getDrawable(R.drawable.bakkle_icon));

            card.setOnCardDimissedListener(new CardModel.OnCardDimissedListener() {
                @Override
                public void onLike() { //the Dislike and like is switched in the library

                    Log.d("Swipeable Card", "I did not like it");
                }

                @Override
                public void onDislike() { //the Dislike and like is switched in the library
                    Log.d("Swipeable Card", "I liked it");
                }
            });

            card.setOnClickListener(new CardModel.OnClickListener() {
                @Override
                public void OnClickListener() {
                    Log.d("Swipeable Cards", "I am pressing the card");
                }
            });
            feedItem = null;


            adapter.add(card);



        }
        mCardContainer.setAdapter(adapter);


    }
}
