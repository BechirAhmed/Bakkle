package com.bakkle.bakkle.Fragments;

import android.app.Activity;
import android.app.ListFragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.ListView;

import com.bakkle.bakkle.Activities.ItemDetailActivity;
import com.bakkle.bakkle.Adapters.HoldingAdapter;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * A fragment representing a list of Items.
 * <p/>
 * <p/>
 * Activities containing this fragment MUST implement the {@link OnFragmentInteractionListener}
 * interface.
 */
public class HoldingPatternFragment extends ListFragment {

    SharedPreferences preferences;
    Activity mActivity;
    private OnFragmentInteractionListener mListener;

    ServerCalls serverCalls;

    JsonObject json;

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public HoldingPatternFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        serverCalls = new ServerCalls(mActivity);

        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);

        json = serverCalls.populateHolding(preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"));

        setListAdapter(new HoldingAdapter(mActivity, getItems(json)));
    }


    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mActivity = activity;
        try {
            mListener = (OnFragmentInteractionListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        FeedItem item = (FeedItem) getListAdapter().getItem(position);

        String url = "https://graph.facebook.com/" + item.getSellerFacebookId() + "/picture?width=142&height=142";

        Intent intent = new Intent(mActivity, ItemDetailActivity.class);
        intent.putExtra("title", item.getTitle());
        intent.putExtra("seller", item.getSellerDisplayName());
        intent.putExtra("price", item.getPrice());
        intent.putExtra("distance", item.getDistance(
                preferences.getString("latitude", "0"),
                preferences.getString("longitude", "0")));
        intent.putExtra("sellerImageUrl", url);
        intent.putExtra("description", item.getDescription());
        intent.putExtra("pk", item.getPk());
        intent.putExtra("parent", "holding");
        intent.putStringArrayListExtra("imageURLs", item.getImageUrls());
        startActivity(intent);


        if (mListener != null) {
            // Notify the active callbacks interface (the activity, if the
            // fragment is attached to one) that an item has been selected.
            //mListener.onFragmentInteraction(DummyContent.ITEMS.get(position).id);
        }
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        public void onFragmentInteraction(String id);
    }

    public ArrayList<FeedItem> getItems(JsonObject json)
    {

        JsonArray jsonArray = json.getAsJsonArray("holding_pattern");
        JsonObject item;
        ArrayList<FeedItem> feedItems = new ArrayList<FeedItem>();
        ArrayList<String> tags, imageUrls;
        JsonArray imageUrlArray;
        FeedItem feedItem;
        String tagsString;


        for(JsonElement element : jsonArray)
        {
            item = element.getAsJsonObject().getAsJsonObject("item");
            feedItem = new FeedItem(mActivity);
            //temp = element.getAsJsonObject();

            feedItem.setTitle(item.get("title").getAsString());
            feedItem.setDescription(item.get("description").getAsString());
            feedItem.setSellerDisplayName(item.get("seller").getAsJsonObject().get("display_name").getAsString());
            feedItem.setPrice(item.get("price").getAsString());
            feedItem.setLocation(item.get("location").getAsString()); //TODO: difference between location and sellerlocation??
            feedItem.setMethod(item.get("method").getAsString());
            feedItem.setSellerFacebookId(item.get("seller").getAsJsonObject().get("facebook_id").getAsString());
            feedItem.setPk(item.get("pk").getAsString());


            imageUrlArray = item.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<>();
            for(JsonElement urlElement : imageUrlArray)
            {
                imageUrls.add(urlElement.getAsString());
            }
            feedItem.setImageUrls(imageUrls);

            tagsString = item.get("tags").getAsString();
            tags = new ArrayList<String>(Arrays.asList(tagsString.split(",")));
            feedItem.setTags(tags);

//            tagArray = item.get("tags").getAsJsonArray();
//            tags = new ArrayList<String>();
//            for(JsonElement tagElement : tagArray)
//            {
//                tags.add(tagElement.getAsString());
//            }
//            feedItem.setTags(tags);
            feedItems.add(feedItem);
        }

        return feedItems;

    }

}
