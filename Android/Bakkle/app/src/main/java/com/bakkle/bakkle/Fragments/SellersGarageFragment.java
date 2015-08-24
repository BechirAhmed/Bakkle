package com.bakkle.bakkle.Fragments;

import android.app.Activity;
import android.app.ListFragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.bakkle.bakkle.Activities.GarageItem;
import com.bakkle.bakkle.Adapters.GarageAdapter;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;

/**
 * A fragment representing a list of Items.
 * <p/>
 * <p/>
 * Activities containing this fragment MUST implement the {@link OnFragmentInteractionListener}
 * interface.
 */
public class SellersGarageFragment extends ListFragment
{

    SharedPreferences preferences;
    private OnFragmentInteractionListener mListener;
    ServerCalls serverCalls;
    ArrayList<FeedItem> items = null;
    JsonObject json;
    Activity mActivity;


    // TODO: Rename and change types of parameters
    public static SellersGarageFragment newInstance()
    {
        SellersGarageFragment fragment = new SellersGarageFragment();
//        Bundle args = new Bundle();
//        args.putString(ARG_PARAM1, param1);
//        args.putString(ARG_PARAM2, param2);
//        fragment.setArguments(args);
        return fragment;
    }

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

        Toolbar toolbar = (Toolbar) mActivity.findViewById(R.id.toolbar);

        for(int i = 0; i < toolbar.getChildCount(); i++)
        {
            View v = toolbar.getChildAt(i);
            if(v instanceof ImageView)
            {
                Log.v("this", "this");
                v.setVisibility(View.GONE);
            }
            else if(v instanceof TextView)
            {
                Log.v("that", "that");
                v.setVisibility(View.VISIBLE);
                ((TextView) v).setText("Seller's Garage");
            }
        }


        json = serverCalls.populateGarage(preferences.getString("auth_token", ""), preferences.getString("uuid", ""));

        items = getItems(json);
        setListAdapter(new GarageAdapter(mActivity, items));

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

//    @Override
//    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
//    {
//        return inflater.inflate(R.layout.fragment_sellersgarage, null, false);
//    }

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
//        Intent intent = new Intent(mActivity, ChatListActivity.class);
//        intent.putExtra("itemId", item.getPk());
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
        String pk, sellerFacebookId;


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
            pk = item.get("pk").getAsString();
            feedItem.setPk(pk);


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
