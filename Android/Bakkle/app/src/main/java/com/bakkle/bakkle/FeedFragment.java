package com.bakkle.bakkle;

import android.app.Activity;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.andtinder.model.CardModel;
import com.andtinder.view.CardContainer;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.koushikdutta.ion.Ion;
import com.wenchao.cardstack.CardStack;

import java.util.ArrayList;

/**
 * A simple {@link Fragment} subclass.
 */
public class FeedFragment extends Fragment {

    ServerCalls serverCalls;

    FeedItem feedItem = null;
    CardContainer mCardContainer;

    CardStack mCardStack;

    String status, description, price, postDate, title, buyerRating, sellerDisplayName, sellerLocation, sellerFacebookId, sellerPk, sellerRating, location, pk, method;


    Bitmap bitmap;

    JsonObject jsonResult;

    SharedPreferences.Editor editor;
    SharedPreferences preferences;

    public interface OnCardSelected {
        public void OnCardSelected(FeedItem item);
    }

    OnCardSelected onCardSelected;


    public FeedFragment() {}

    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        try {
            onCardSelected = (OnCardSelected) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString() + " must implement OnCardSelected");
        }
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_feed, container, false);

        preferences = PreferenceManager.getDefaultSharedPreferences(getActivity().getApplicationContext());

        serverCalls = new ServerCalls(getActivity().getApplicationContext());

        try{
            new bgTask().execute();
        }
        catch (Exception e){Log.d("testing", e.getMessage());}


//        mCardContainer = (CardContainer) view.findViewById(R.id.cardView);
//        mCardContainer.setOrientation(Orientations.Orientation.Ordered);

        mCardStack = (CardStack) view.findViewById(R.id.container);
        mCardStack.setContentResource(R.layout.card_layout);
        mCardStack.setStackMargin(0);

        return view;
    }

    public void populateFeed(JsonObject json)
    {
        JsonArray jsonArray = json.getAsJsonArray("feed");
        //SimpleCardStackAdapter adapter = new SimpleCardStackAdapter(getActivity());
        CardAdapter mCardAdapter = new CardAdapter(getActivity().getApplicationContext());
        JsonObject temp;
        ArrayList<FeedItem> feedItems = new ArrayList<>();
        CardModel card;
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray;


        for(JsonElement element : jsonArray)
        {
            feedItem = new FeedItem(this.getActivity().getApplicationContext());
            temp = element.getAsJsonObject();

            feedItem.setTitle(temp.get("title").getAsString());
            feedItem.setDescription(temp.get("description").getAsString());
            feedItem.setSellerDisplayName(temp.get("seller").getAsJsonObject().get("display_name").getAsString());
            feedItem.setPrice(temp.get("price").getAsString());
            feedItem.setLocation(temp.get("location").getAsString()); //TODO: difference between location and sellerlocation??
            feedItem.setMethod(temp.get("method").getAsString());
            feedItem.setSellerFacebookId(temp.get("seller").getAsJsonObject().get("facebook_id").getAsString());
            pk = temp.get("pk").getAsString();
            feedItem.setPk(pk);


            imageUrlArray = temp.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<>();
            for(JsonElement urlElement : imageUrlArray)
            {
                imageUrls.add(urlElement.getAsString());
            }
            feedItem.setImageUrls(imageUrls);

            mCardAdapter.add(feedItem);
            mCardStack.setAdapter(mCardAdapter);

            /*card = new CardModel(feedItem.getTitle(), feedItem.getSellerDisplayName(), "$" + feedItem.getPrice(),
                    feedItem.getDistance(), feedItem.getMethod(), getCardImage(feedItem), getSellerImage(sellerFacebookId));

            card.setOnCardDismissedListener(new CardModel.OnCardDismissedListener() {
                @Override
                public void onLike() {
                    Toast.makeText(getActivity(), "Like", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("want",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            pk,
                            "42");
                }

                @Override
                public void onDislike() {
                    Toast.makeText(getActivity(), "Dislike", Toast.LENGTH_SHORT).show();

                    serverCalls.markItem("meh",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            pk,
                            "42");
                }

                @Override
                public void onUp() {
                    Toast.makeText(getActivity(), "Up", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("hold",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            pk,
                            "42");

                }

                @Override
                public void onDown() {
                    Toast.makeText(getActivity(), "Down", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("report",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            pk,
                            "42");

                }
            });
            final CardModel tempCard = card;
            card.setOnClickListener(new CardModel.OnClickListener() {
                @Override
                public void OnClickListener() {
                    //onCardSelected.OnCardSelected(feedItem);
//title, tags, img, method, price


                    //TODO: bring up description page, with all pictures, description, etc
                }
            });

            adapter.add(card);
            mCardContainer.setAdapter(adapter);*/
            feedItem = null;
//            temp = null;
//            imageUrlArray = null;
//            imageUrls = null;
            //card = null;
        }


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
            Log.d("testing error 1122", e.getMessage());
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

    private class bgTask extends AsyncTask<Void, Void, JsonObject>
    {
        ProgressDialog dialog = new ProgressDialog(getActivity()); //TODO: Change from progress dialog to spinner

        @Override
        protected void onPreExecute(){
            this.dialog.setMessage("Please wait");
            this.dialog.show();
        }
        @Override
        protected JsonObject doInBackground(Void... voids) {

            return serverCalls.getFeedItems(
                    preferences.getString("auth_token", "0"),
                    "99999999",
                    "100",
                    "",
                    "32,32",
                    "",
                    preferences.getString("uuid", "0")
            );
        }

        @Override
        protected void onPostExecute(JsonObject jsonObject) {
            jsonResult = jsonObject;
            if (dialog.isShowing()) {
                dialog.dismiss();
            }

            if(jsonResult != null)
                populateFeed(jsonResult);
            else
                Log.d("umm", "what");
        }
    }
}
