package com.bakkle.bakkle.Fragments;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.widget.SearchView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.andtinder.model.CardModel;
import com.andtinder.model.Orientations;
import com.andtinder.view.CardContainer;
import com.andtinder.view.SimpleCardStackAdapter;
import com.bakkle.bakkle.Activities.HomeActivity;
import com.bakkle.bakkle.Activities.ItemDetailActivity;
import com.bakkle.bakkle.Helpers.Constants;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;


public class FeedFragment extends Fragment
{
    ServerCalls serverCalls;
    Activity    mActivity;
    FeedItem feedItem = null;
    CardContainer mCardContainer;
    private SearchView  searchView;
    private ProgressBar bar;
    CardModel                card;
    SharedPreferences.Editor editor;
    SharedPreferences        preferences;

    public interface OnCardSelected
    {
        void OnCardSelected(FeedItem item);
    }

    OnCardSelected onCardSelected;

    public static FeedFragment newInstance(boolean showTutorial)
    {
        FeedFragment fragment = new FeedFragment();
        Bundle args = new Bundle();
        args.putBoolean(Constants.SHOW_TUORIAL, showTutorial);
        fragment.setArguments(args);
        return fragment;
    }


    public FeedFragment() {}

    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        mActivity = activity;
    }

    @Override
    public void onResume()
    {
        super.onResume();
        new bgTask().execute();
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_feed, container, false);

        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);

        serverCalls = new ServerCalls(mActivity);
        mCardContainer = (CardContainer) view.findViewById(R.id.cardView);
        mCardContainer.setOrientation(Orientations.Orientation.Ordered);
        bar = (ProgressBar) view.findViewById(R.id.spinner);
        searchView = (SearchView) view.findViewById(R.id.searchField);
        searchView.setQuery(preferences.getString(Constants.SEARCH_TEXT, ""), false);
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener()
        {
            @Override
            public boolean onQueryTextSubmit(String s)
            {
                editor.putString(Constants.SEARCH_TEXT, s);
                editor.apply();
                ((HomeActivity) mActivity).hideSoftKeyBoard();
                getFragmentManager().beginTransaction().replace(R.id.content_frame, new FeedFragment())
                        .disallowAddToBackStack().setTransition(android.app.FragmentTransaction.TRANSIT_FRAGMENT_CLOSE)
                        .commit();
                return true;
            }

            @Override
            public boolean onQueryTextChange(String s)
            {
                editor.putString(Constants.SEARCH_TEXT, s);
                editor.apply();
                return false;
            }
        });

        try {
            new bgTask().execute();
        }
        catch (Exception e) {
            Log.d("Error", e.getMessage());
        }
        return view;
    }

    public void populateFeed(JsonArray jsonArray)
    {

        final SimpleCardStackAdapter adapter = new SimpleCardStackAdapter(mActivity);
        JsonObject temp;
        ArrayList<FeedItem> feedItems = new ArrayList<>();
        ArrayList<String> imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray;
        JsonElement element;

        for (int i = jsonArray.size() - 1; i >= 0; i--) {
            element = jsonArray.get(i);
            feedItem = new FeedItem(mActivity);
            temp = element.getAsJsonObject();

            feedItem.setTitle(temp.get("title").getAsString());
            feedItem.setSellerDisplayName(temp.get("seller").getAsJsonObject().get("display_name").getAsString());
            feedItem.setSellerFacebookId(temp.get("seller").getAsJsonObject().get("facebook_id").getAsString());
            feedItem.setPrice(temp.get("price").getAsString());
            feedItem.setLocation(temp.get("location").getAsString()); //TODO: difference between location and sellerlocation??
            feedItem.setMethod(temp.get("method").getAsString());
            feedItem.setDescription(temp.get("description").getAsString());
            feedItem.setSellerFacebookId(temp.get("seller").getAsJsonObject().get("facebook_id").getAsString());
            feedItem.setPk(temp.get("pk").getAsString());

            imageUrlArray = temp.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<>();
            for (JsonElement urlElement : imageUrlArray) {
                imageUrls.add(urlElement.getAsString());
            }

            feedItem.setImageUrls(imageUrls);

            card = new CardModel(
                    feedItem.getTitle(),
                    feedItem.getSellerDisplayName(),
                    "$" + feedItem.getPrice(),
                    feedItem.getDistance(
                            preferences.getString(Constants.LATITUDE, "0"),
                            preferences.getString(Constants.LONGITUDE, "0")),
                    feedItem.getMethod(),
                    feedItem.getPk(),
                    feedItem.getDescription(),
                    feedItem.getImageUrls(),
                    "http://graph.facebook.com/" + feedItem.getSellerFacebookId() + "/picture?width=64&height=64"/*, getCardImage(feedItem), getSellerImage(sellerFacebookId)*/);

            card.setOnCardDismissedListener(new CardModel.OnCardDismissedListener()
            {
                @Override
                public void onLike(CardModel cardModel)
                {
                    Toast.makeText(mActivity, "Want", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("want",
                            preferences.getString(Constants.AUTH_TOKEN, "0"),
                            preferences.getString(Constants.UUID, "0"),
                            cardModel.getPk(),
                            "42");
                    showSplashScreen(cardModel.getPk(), cardModel.getCardImageURL());
                }

                @Override
                public void onDislike(CardModel cardModel)
                {
                    Toast.makeText(mActivity, "Nope", Toast.LENGTH_SHORT).show();

                    serverCalls.markItem("meh",
                            preferences.getString(Constants.AUTH_TOKEN, "0"),
                            preferences.getString(Constants.UUID, "0"),
                            cardModel.getPk(),
                            "42");
                }

                @Override
                public void onUp(CardModel cardModel)
                {
                    Toast.makeText(mActivity, "Holding", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("hold",
                            preferences.getString(Constants.AUTH_TOKEN, "0"),
                            preferences.getString(Constants.UUID, "0"),
                            cardModel.getPk(),
                            "42");
                }

                @Override
                public void onDown(CardModel cardModel)
                {
                    Toast.makeText(mActivity, "Report", Toast.LENGTH_SHORT).show();
                    serverCalls.markItem("report",
                            preferences.getString(Constants.AUTH_TOKEN, "0"),
                            preferences.getString(Constants.UUID, "0"),
                            cardModel.getPk(),
                            "42");
                }
            });
            card.setOnClickListener(new CardModel.OnClickListener()
            {
                @Override
                public void OnClickListener(CardModel cardModel)
                {
                    Intent intent = new Intent(mActivity, ItemDetailActivity.class);
                    intent.putExtra(Constants.TITLE, cardModel.getTitle());
                    intent.putExtra(Constants.SELLER, cardModel.getSeller());
                    intent.putExtra(Constants.PRICE, cardModel.getPrice());
                    intent.putExtra(Constants.DISTANCE, cardModel.getDistance());
                    intent.putExtra(Constants.SELLER_IMAGE_URL, cardModel.getSellerImageURL());
                    intent.putExtra(Constants.DESCRIPTION, cardModel.getDescription());
                    intent.putExtra(Constants.PK, cardModel.getPk());
                    intent.putStringArrayListExtra(Constants.IMAGE_URLS, cardModel.getImageURLs());
                    intent.putExtra(Constants.PARENT, "feed");
                    startActivityForResult(intent, 1);
                }
            });

            adapter.add(card);

        }
        if(getArguments() != null && getArguments().containsKey(Constants.SHOW_TUORIAL) && getArguments().getBoolean(Constants.SHOW_TUORIAL, false))
        {
            card = new CardModel();
            adapter.add(card);
        }
        mCardContainer.setAdapter(adapter);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        if (data != null && data.getBooleanExtra("markWant", false))
            mCardContainer.like();
    }

    private void showSplashScreen(String pk, String url)
    {
        getFragmentManager().beginTransaction().replace(R.id.content_frame,
                SplashFragment.newInstance(pk, url)).addToBackStack(null).
                setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
    }


    public class bgTask extends AsyncTask<Void, Void, JsonObject>
    {
        @Override
        protected void onPreExecute()
        {
            bar.setVisibility(View.VISIBLE);
        }

        @Override
        protected JsonObject doInBackground(Void... voids)
        {
            return serverCalls.getFeedItems(
                    preferences.getString(Constants.AUTH_TOKEN, "0"),
                    preferences.getInt(Constants.PRICE_FILTER, 100) + "",
                    preferences.getInt(Constants.DISTANCE_FILTER, 100) + "",
                    preferences.getString(Constants.SEARCH_TEXT, ""),
                    preferences.getString(Constants.LOCATION, "0, 0"),
                    "",
                    preferences.getString(Constants.UUID, "0")
            );
        }

        @Override
        protected void onPostExecute(JsonObject jsonObject)
        {
            bar.setVisibility(View.GONE);
            populateFeed(jsonObject.getAsJsonArray("feed"));
        }
    }
}
