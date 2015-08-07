package com.bakkle.bakkle.Fragments;

import android.app.ActionBar;
import android.app.Activity;
import android.app.ListFragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.widget.ListView;

import com.andtinder.view.SimpleCardStackAdapter;
import com.bakkle.bakkle.Activities.ChatActivity;
import com.bakkle.bakkle.Adapters.TrunkAdapter;
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
public class BuyersTrunkFragment extends ListFragment{



    SharedPreferences preferences;

    private OnFragmentInteractionListener mListener;

    ServerCalls serverCalls;

    ArrayList<FeedItem> items;

    JsonObject json;

    private ActionBar mActionBar;


    // TODO: Rename and change types of parameters
    public static BuyersTrunkFragment newInstance(String param1, String param2) {
        BuyersTrunkFragment fragment = new BuyersTrunkFragment();
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
    public BuyersTrunkFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setHasOptionsMenu(true);

        serverCalls = new ServerCalls(getActivity().getApplicationContext());

        preferences = PreferenceManager.getDefaultSharedPreferences(getActivity());

        json = serverCalls.populateTrunk(preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"));

        items = getItems(json);

        /*if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }*/

        setListAdapter(new TrunkAdapter(getActivity(), items));


    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater){

        //super.onCreateOptionsMenu(menu, inflater);
        menu.clear();

//        mActionBar = getActivity().getActionBar();
//        mActionBar.setDisplayShowHomeEnabled(false);
//        mActionBar.setDisplayShowTitleEnabled(false);
        LayoutInflater mInflater = LayoutInflater.from(getActivity());

        //View mCustomView = mInflater.inflate(R.layout.action_bar_trunk, null);

//        mActionBar.setCustomView(mCustomView);
//        mActionBar.setDisplayShowCustomEnabled(true);
    }


    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
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
        Intent intent = new Intent(getActivity(), ChatActivity.class);
        intent.putExtra("id", item.getPk()); //make sure to let the chat app window know if youre the buyer or seller somehow
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
        JsonArray jsonArray = json.get("buyers_trunk").getAsJsonArray();;
        SimpleCardStackAdapter adapter = new SimpleCardStackAdapter(getActivity());
        JsonObject temp, item;
        ArrayList<FeedItem> feedItems = new ArrayList<FeedItem>();
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray, tagArray;
        FeedItem feedItem;
        String pk, sellerFacebookId;
        String tagsString;

        for(JsonElement element : jsonArray)
        {
            item = element.getAsJsonObject().getAsJsonObject("item");
            feedItem = new FeedItem(this.getActivity().getApplicationContext());
            temp = element.getAsJsonObject();

            feedItem.setTitle(item.get("title").getAsString());
            feedItem.setDescription(item.get("description").getAsString());
            feedItem.setSellerDisplayName(item.get("seller").getAsJsonObject().get("display_name").getAsString());
            feedItem.setPrice(item.get("price").getAsString());
            feedItem.setLocation(item.get("location").getAsString()); //TODO: difference between location and sellerlocation??
            feedItem.setMethod(item.get("method").getAsString());
            sellerFacebookId = item.get("seller").getAsJsonObject().get("facebook_id").getAsString();
            pk = item.get("pk").getAsString();
            feedItem.setPk(pk);


            imageUrlArray = item.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<String>();
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


            feedItem = null;
            temp = null;
            imageUrlArray = null;
            imageUrls = null;
            item = null;
        }

        return feedItems;

    }



}
