package com.bakkle.bakkle.Fragments;

import android.app.ActionBar;
import android.app.Activity;
import android.app.ListFragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.widget.ListView;

import com.andtinder.view.SimpleCardStackAdapter;
import com.bakkle.bakkle.Activities.ChatActivity;
import com.bakkle.bakkle.Adapters.TrunkAdapter;
import com.bakkle.bakkle.Helpers.ChatCalls;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.WebSocket;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;


public class BuyersTrunkFragment extends ListFragment
{


    SharedPreferences preferences;

    private OnFragmentInteractionListener mListener;

    ServerCalls serverCalls;
    Activity mActivity;
    ArrayList<FeedItem> items;
    String uuid;
    String authToken;
    JsonObject json;

    private ActionBar mActionBar;


    // TODO: Rename and change types of parameters
    public static BuyersTrunkFragment newInstance(String param1, String param2)
    {
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
    public BuyersTrunkFragment()
    {
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        setHasOptionsMenu(true);

        serverCalls = new ServerCalls(mActivity);

        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);
        uuid = preferences.getString("uuid", "");
        authToken = preferences.getString("auth_token", "");
        json = serverCalls.populateTrunk(authToken, uuid);

        items = getItems(json);

        /*if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }*/

        setListAdapter(new TrunkAdapter(mActivity, items));


    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {

        //super.onCreateOptionsMenu(menu, inflater);
        menu.clear();

//        mActionBar = mActivity.getActionBar();
//        mActionBar.setDisplayShowHomeEnabled(false);
//        mActionBar.setDisplayShowTitleEnabled(false);
        LayoutInflater mInflater = LayoutInflater.from(mActivity);

        //View mCustomView = mInflater.inflate(R.layout.action_bar_trunk, null);

//        mActionBar.setCustomView(mCustomView);
//        mActionBar.setDisplayShowCustomEnabled(true);
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
        new StartChatIntermediary(item.getPk());


        if (mListener != null) {
            // Notify the active callbacks interface (the activity, if the
            // fragment is attached to one) that an item has been selected.
            //mListener.onFragmentInteraction(DummyContent.ITEMS.get(position).id);
        }
    }

    private class StartChatIntermediary
    {
        public StartChatIntermediary(String pk)
        {
            ChatCalls chatCalls = new ChatCalls(uuid, authToken.substring(33, 35), authToken, new WebSocketCallBack(pk));
            chatCalls.connect();
        }
    }

    private class WebSocketCallBack implements AsyncHttpClient.WebSocketConnectCallback
    {
        String pk;
        public WebSocketCallBack(String pk) {this.pk = pk;}

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if(ex != null)
            {
                Log.e("callback exception", ex.getMessage());
                return;
            }
            JSONObject json = new JSONObject();
            try {
                json.put("method", "chat_startChat");
                json.put("itemId", pk);
                json.put("uuid", uuid);
                json.put("auth_token", authToken);
//                json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
//                json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
            }
            catch (Exception e) {
                Log.e("Websocket callback", e.getMessage());
            }

            webSocket.send(json.toString());
            webSocket.setStringCallback(new WebSocket.StringCallback()
            {
                @Override
                public void onStringAvailable(String s)
                {
                    JsonParser jsonParser = new JsonParser();
                    JsonElement jsonElement = jsonParser.parse(s);
                    JsonObject jsonObject = jsonElement.getAsJsonObject();
                    if(!jsonObject.has("chatId"))
                        return;
                    Intent i = new Intent(mActivity, ChatActivity.class);
                    i.putExtra("chatId", Integer.parseInt(jsonObject.get("chatId").getAsString()));
                    i.putExtra("selfBuyer", true);
                    startActivity(i);
                }
            });
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
        JsonArray jsonArray = json.get("buyers_trunk").getAsJsonArray();
        ;
        SimpleCardStackAdapter adapter = new SimpleCardStackAdapter(mActivity);
        JsonObject temp, item;
        ArrayList<FeedItem> feedItems = new ArrayList<FeedItem>();
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray, tagArray;
        FeedItem feedItem;
        String pk, sellerFacebookId;
        String tagsString;

        for (JsonElement element : jsonArray) {
            item = element.getAsJsonObject().getAsJsonObject("item");
            feedItem = new FeedItem(mActivity);
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
            for (JsonElement urlElement : imageUrlArray) {
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
