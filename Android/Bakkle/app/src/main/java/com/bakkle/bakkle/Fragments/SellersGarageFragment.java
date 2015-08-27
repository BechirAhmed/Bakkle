package com.bakkle.bakkle.Fragments;

import android.app.Activity;
import android.app.ListFragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.ListView;

import com.bakkle.bakkle.Activities.GarageItem;
import com.bakkle.bakkle.Adapters.GarageAdapter;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;


public class SellersGarageFragment extends ListFragment
{

    SharedPreferences preferences;
    private OnFragmentInteractionListener mListener;
    ServerCalls serverCalls;
    JsonObject json;
    Activity mActivity;

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public SellersGarageFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        serverCalls = new ServerCalls(mActivity);
        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);

//        Toolbar toolbar = (Toolbar) mActivity.findViewById(R.id.toolbar);
//
//        for(int i = 0; i < toolbar.getChildCount(); i++)
//        {
//            View v = toolbar.getChildAt(i);
//            if(v instanceof ImageView)
//            {
//                Log.v("this", "this");
//                v.setVisibility(View.GONE);
//            }
//            else if(v instanceof TextView)
//            {
//                Log.v("that", "that");
//                v.setVisibility(View.VISIBLE);
//                ((TextView) v).setText("Seller's Garage");
//            }
//        }
//

        json = serverCalls.populateGarage(preferences.getString("auth_token", ""), preferences.getString("uuid", ""));
        setListAdapter(new GarageAdapter(mActivity, getItems(json)));
    }


    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        mActivity = activity;
        try {
            mListener = (OnFragmentInteractionListener) activity;
        }
        catch (ClassCastException e) {
            throw new ClassCastException(activity.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach()
    {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id)
    {
        super.onListItemClick(l, v, position, id);

        FeedItem item = (FeedItem) getListAdapter().getItem(position);
        Intent intent = new Intent(mActivity, GarageItem.class);
        intent.putExtra("itemId", item.getPk());
        intent.putExtra("numWant", item.getNumWant());
        intent.putExtra("numHold", item.getNumHold());
        intent.putExtra("numMeh", item.getNumMeh());
        intent.putExtra("numView", item.getNumView());
        intent.putExtra("title", item.getTitle());
        intent.putExtra("seller", item.getSellerDisplayName());
        intent.putExtra("price", item.getPrice());
        intent.putExtra("distance", item.getDistance(preferences.getString("latitude", ""), preferences.getString("longitude", "")));
        intent.putExtra("sellerImageUrl", "http://graph.facebook.com/" + item.getSellerFacebookId() + "/picture?width=142&height=142");
        intent.putExtra("description", item.getDescription());
        intent.putExtra("pk", item.getPk());
        intent.putStringArrayListExtra("imageURLs", item.getImageUrls());

        startActivity(intent);
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
    public interface OnFragmentInteractionListener
    {
        // TODO: Update argument type and name
        public void onFragmentInteraction(String id);
    }

    public ArrayList<FeedItem> getItems(JsonObject json)
    {

        JsonArray jsonArray = json.getAsJsonArray("seller_garage");
        JsonObject temp, item;
        ArrayList<FeedItem> feedItems = new ArrayList<>();
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray, tagArray;
        FeedItem feedItem;

        for (JsonElement element : jsonArray) {
            item = element.getAsJsonObject();
            temp = item.getAsJsonObject("seller");

            feedItem = new FeedItem(mActivity);

            feedItem.setTitle(item.get("title").getAsString());
            feedItem.setPrice(item.get("price").getAsString());
            feedItem.setNumView(item.get("number_of_views").getAsString());
            feedItem.setNumMeh(item.get("number_of_meh").getAsString());
            feedItem.setNumWant(item.get("number_of_want").getAsString());
            feedItem.setNumHold(item.get("number_of_holding").getAsString());
            feedItem.setLocation(item.get("location").getAsString());
            feedItem.setPk(item.get("pk").getAsString());

            imageUrlArray = item.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<>();
            for (JsonElement urlElement : imageUrlArray) {
                imageUrls.add(urlElement.getAsString());
            }
            feedItem.setImageUrls(imageUrls);

            feedItems.add(feedItem);
        }
        return feedItems;
    }
}
