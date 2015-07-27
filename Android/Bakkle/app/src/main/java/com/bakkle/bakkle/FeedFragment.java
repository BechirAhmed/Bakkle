package com.bakkle.bakkle;

import android.app.Activity;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

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
public class FeedFragment extends Fragment {

    ServerCalls serverCalls;

    FeedItem feedItem = null;
    CardContainer mCardContainer;

    CardModel card;

    //CardStack mCardStack;

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


        mCardContainer = (CardContainer) view.findViewById(R.id.cardView);
        mCardContainer.setOrientation(Orientations.Orientation.Ordered);

//        mCardStack = (CardStack) view.findViewById(R.id.container);
//        mCardStack.setContentResource(R.layout.card_layout);
//        mCardStack.setStackMargin(0);

        return view;
    }

    public void populateFeed(JsonArray jsonArray)
    {

        final SimpleCardStackAdapter adapter = new SimpleCardStackAdapter(getActivity());
        JsonObject temp;
        ArrayList<FeedItem> feedItems = new ArrayList<>();
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray;
        JsonElement element;

        for(int i = jsonArray.size() - 1; i >= 0; i--) {
            element = jsonArray.get(i);
            feedItem = new FeedItem(getActivity().getApplicationContext());
            temp = element.getAsJsonObject();

            feedItem.setTitle(temp.get("title").getAsString());
            feedItem.setSellerDisplayName(temp.get("seller").getAsJsonObject().get("display_name").getAsString());
            feedItem.setSellerFacebookId(temp.get("seller").getAsJsonObject().get("facebook_id").getAsString());
            feedItem.setPrice(temp.get("price").getAsString());
            feedItem.setLocation(temp.get("location").getAsString()); //TODO: difference between location and sellerlocation??
            feedItem.setMethod(temp.get("method").getAsString());
            feedItem.setDescription(temp.get("description").getAsString());
            feedItem.setSellerFacebookId(temp.get("seller").getAsJsonObject().get("facebook_id").getAsString());
            pk = temp.get("pk").getAsString();
            feedItem.setPk(pk);


            imageUrlArray = temp.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<>();
            for (JsonElement urlElement : imageUrlArray) {
                imageUrls.add(urlElement.getAsString());
            }
            feedItem.setImageUrls(imageUrls);


            card = new CardModel(feedItem.getTitle(), feedItem.getSellerDisplayName(), "$" + feedItem.getPrice(),
                    feedItem.getDistance(), feedItem.getMethod(), feedItem.getPk(), feedItem.getDescription(),
                    feedItem.getImageUrls(),
                    "http://graph.facebook.com/" + feedItem.getSellerFacebookId() + "/picture?type=square"/*, getCardImage(feedItem), getSellerImage(sellerFacebookId)*/);

            card.setOnCardDismissedListener(new CardModel.OnCardDismissedListener() {
                @Override
                public void onLike(CardModel cardModel) {
                    Toast.makeText(getActivity(), "Want", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("want",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            cardModel.getPk(),
                            "42");
                    //populateOneFeedItem(jsonArray);


                    Log.v("pk is ", cardModel.getPk());
                }

                @Override
                public void onDislike(CardModel cardModel) {
                    Toast.makeText(getActivity(), "Nope", Toast.LENGTH_SHORT).show();

                    serverCalls.markItem("meh",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            cardModel.getPk(),
                            "42");
                    //populateOneFeedItem(jsonArray);
                }

                @Override
                public void onUp(CardModel cardModel) {
                    Toast.makeText(getActivity(), "Holding", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("hold",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            cardModel.getPk(),
                            "42");
                    //populateOneFeedItem(jsonArray);

                }

                @Override
                public void onDown(CardModel cardModel) {
                    Toast.makeText(getActivity(), "Comment", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("report",
                            preferences.getString("auth_token", "0"),
                            preferences.getString("uuid", "0"),
                            cardModel.getPk(),
                            "42");
                    //populateOneFeedItem(jsonArray);

                }
            });
            card.setOnClickListener(new CardModel.OnClickListener() {
                @Override
                public void OnClickListener(CardModel cardModel) {
                    //onCardSelected.OnCardSelected(feedItem);
                    //title, tags, img, method, price
                    Intent intent = new Intent(FeedFragment.this.getActivity(), ItemDetail.class);
                    intent.putExtra("title", cardModel.getTitle());
                    intent.putExtra("seller", cardModel.getSeller());
                    intent.putExtra("price", cardModel.getPrice());
                    intent.putExtra("distance", cardModel.getDistance());
                    intent.putExtra("sellerImageUrl", cardModel.getSellerImageURL());
                    intent.putExtra("description", cardModel.getDescription());
                    intent.putExtra("pk", cardModel.getPk());
                    intent.putExtra("url1", cardModel.getCardImageURL());
                    //intent.putStringArrayListExtra("imageUrls", cardModel.getImageURLs());
                    startActivity(intent);

                    //TODO: bring up description page, with all pictures, description, etc
                }
            });


            adapter.add(card);
            mCardContainer.setAdapter(adapter);
        }
        //jsonArray = populateOneFeedItem(jsonArray);
    }

    public JsonArray populateOneFeedItem(final JsonArray jsonArray)
    {
        final SimpleCardStackAdapter adapter = new SimpleCardStackAdapter(getActivity());
        //CardAdapter mCardAdapter = new CardAdapter(getActivity().getApplicationContext());
        JsonObject temp;
        ArrayList<FeedItem> feedItems = new ArrayList<>();
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray;
        JsonElement element;

        element = jsonArray.remove(jsonArray.size() - 1);

        feedItem = new FeedItem(this.getActivity().getApplicationContext());
        temp = element.getAsJsonObject();

        feedItem.setTitle(temp.get("title").getAsString());
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

        //mCardAdapter.add(feedItem);
        //mCardStack.setAdapter(mCardAdapter);

        card = new CardModel(feedItem.getTitle(), feedItem.getSellerDisplayName(), "$" + feedItem.getPrice(),
                feedItem.getDistance(), feedItem.getMethod(), feedItem.getPk(), feedItem.getDescription(),
                feedItem.getImageUrls(),
                "http://graph.facebook.com/" + feedItem.getSellerFacebookId() + "/picture?type=square"/*, getCardImage(feedItem), getSellerImage(sellerFacebookId)*/);
        card.setOnCardDismissedListener(new CardModel.OnCardDismissedListener() {
            @Override
            public void onLike(CardModel cardModel) {
                Toast.makeText(getActivity(), "Want", Toast.LENGTH_SHORT).show();
                serverCalls.markItem("want",
                        preferences.getString("auth_token", "0"),
                        preferences.getString("uuid", "0"),
                        cardModel.getPk(),
                        "42");
                populateOneFeedItem(jsonArray);


                Log.v("pk is ", card.getPk());
            }

            @Override
            public void onDislike(CardModel cardModel) {
                Toast.makeText(getActivity(), "Nope", Toast.LENGTH_SHORT).show();

                serverCalls.markItem("meh",
                        preferences.getString("auth_token", "0"),
                        preferences.getString("uuid", "0"),
                        cardModel.getPk(),
                        "42");
                populateOneFeedItem(jsonArray);
            }

            @Override
            public void onUp(CardModel cardModel) {
                Toast.makeText(getActivity(), "Holding", Toast.LENGTH_SHORT).show();
                serverCalls.markItem("hold",
                        preferences.getString("auth_token", "0"),
                        preferences.getString("uuid", "0"),
                        cardModel.getPk(),
                        "42");
                populateOneFeedItem(jsonArray);

            }

            @Override
            public void onDown(CardModel cardModel) {
                Toast.makeText(getActivity(), "Comment", Toast.LENGTH_SHORT).show();
                serverCalls.markItem("report",
                        preferences.getString("auth_token", "0"),
                        preferences.getString("uuid", "0"),
                        cardModel.getPk(),
                        "42");
                populateOneFeedItem(jsonArray);

            }
        });
        card.setOnClickListener(new CardModel.OnClickListener() {
            @Override
            public void OnClickListener(CardModel cardModel) {
                //onCardSelected.OnCardSelected(feedItem);
                //title, tags, img, method, price


                //TODO: bring up description page, with all pictures, description, etc
            }
        });

        adapter.add(card);
        mCardContainer.setAdapter(adapter);

        return jsonArray;
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
            this.dialog.setMessage("Loading Items");
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
                populateFeed(jsonResult.getAsJsonArray("feed"));
            else
                Log.d("umm", "what");
        }
    }
}
