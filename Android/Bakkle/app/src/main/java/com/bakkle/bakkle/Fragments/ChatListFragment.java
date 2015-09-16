package com.bakkle.bakkle.Fragments;


import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import com.bakkle.bakkle.Activities.ChatActivity;
import com.bakkle.bakkle.Adapters.ChatListAdapter;
import com.bakkle.bakkle.Helpers.BuyerInfo;
import com.bakkle.bakkle.Helpers.ChatCalls;
import com.bakkle.bakkle.Helpers.Constants;
import com.bakkle.bakkle.R;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.WebSocket;

import org.json.JSONObject;

import java.util.ArrayList;


public class ChatListFragment extends ListFragment
{
    private String itemId;
    ArrayList<BuyerInfo> buyerInfos = null;
    JsonObject json;
    SharedPreferences preferences;
    ChatCalls chatCalls;
    ChatListAdapter chatListAdapter;
    String response;
    protected String authToken;
    public Activity mActivity;
    String uuid;
    String title, price, description, seller, distance, pk, sellerImageUrl;
    ArrayList<String> imageURLs;

    public static ChatListFragment newInstance(String itemId, String title, String price, String description,
                                               String seller, String distance, String pk, String sellerImageUrl,
                                               ArrayList<String> imageURLs)
    {
        ChatListFragment fragment = new ChatListFragment();
        Bundle args = new Bundle();
        args.putString("itemId", itemId);
        args.putString("title", title);
        args.putString("seller", seller);
        args.putString("price", price);
        args.putString("distance", distance);
        args.putString("sellerImageUrl", sellerImageUrl);
        args.putString("description", description);
        args.putString("pk", pk);
        args.putStringArrayList("imageUrls", imageURLs);

        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        mActivity = activity;
    }
    
    public ChatListFragment() {}
    
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        Bundle b = getArguments();
        if (getArguments() != null) {
            itemId = b.getString(Constants.ITEM_ID);
            title = b.getString(Constants.TITLE);
            seller = b.getString(Constants.SELLER);
            price = b.getString(Constants.PRICE);
            distance = b.getString(Constants.DISTANCE);
            sellerImageUrl = b.getString(Constants.SELLER_IMAGE_URL);
            description = b.getString(Constants.DESCRIPTION);
            pk = b.getString(Constants.PK);
            imageURLs = b.getStringArrayList(Constants.IMAGE_URLS);
        }
        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);
        uuid = preferences.getString(Constants.UUID, "");
        authToken = preferences.getString(Constants.AUTH_TOKEN, "");

        buyerInfos = new ArrayList<>();
        chatListAdapter = new ChatListAdapter(mActivity, buyerInfos);
        setListAdapter(chatListAdapter);

        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);
        chatCalls = new ChatCalls(uuid, authToken.substring(33, 35), authToken, new WebSocketCallBack());
        chatCalls.connect();

//        Intent i = new Intent(this, ChatCalls.class);
//        i.putExtra("uuid", preferences.getString("uuid", ""));
//        i.putExtra("auth_token", authToken);
//        i.putExtra("sellerPk", authToken.substring(33, 35));
//        startService(i);
    }
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_chat_list, null, false);
        return view;
    }


    private class WebSocketCallBack implements AsyncHttpClient.WebSocketConnectCallback
    {

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if(ex != null)
            {
                Log.v("callback exception", "" + ex.getMessage());
                return;
            }
            JSONObject json = new JSONObject();
            Log.v("itemId is", itemId);
            try {
                json.put("method", "chat_getChatIds");
                json.put("itemId", itemId);
                json.put("uuid", uuid);
                json.put("auth_token", authToken);
            }
            catch (Exception e) {
                Log.v("Websocket callback", e.getMessage());
            }

            webSocket.send(json.toString());
            webSocket.setStringCallback(new WebSocket.StringCallback()
            {
                @Override
                public void onStringAvailable(String s)
                {
                    response = s;
                    Log.v("response is", response);
                    populateList(response);
                }
            });

        }
    }

    public void populateList(String result)
    {
        JsonParser jsonParser = new JsonParser();
        JsonElement jsonElement = jsonParser.parse(result);
        JsonObject jsonObject = jsonElement.getAsJsonObject();
        int status = jsonObject.get("success").getAsInt();
        if(status != 1 || jsonObject.has("message"))
            return;
        Log.v("testing", result);
        JsonArray chatArray = jsonObject.get("chats").getAsJsonArray();
        for(JsonElement element : chatArray)
        {
            JsonObject temp = element.getAsJsonObject();
            JsonObject buyer = temp.getAsJsonObject("buyer");
            String url = "https://graph.facebook.com/" + buyer.get("facebook_id").getAsString() + "/picture?width=142&height=142";
            buyerInfos.add(new BuyerInfo(buyer.get("display_name").getAsString(), url, temp.get("pk").getAsInt()));
        }
        mActivity.runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                chatListAdapter.notifyDataSetChanged();
            }
        });

        //JsonObject buyerObject = chatArray.get(0).getAsJsonObject().get("buyer").getAsJsonObject()
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);
        BuyerInfo buyerInfo = (BuyerInfo) getListAdapter().getItem(position);
        Intent intent = new Intent(mActivity, ChatActivity.class);
        intent.putExtra(Constants.CHAT_ID, buyerInfo.getChatPk());
        intent.putExtra(Constants.SELF_BUYER, false);
        intent.putExtra(Constants.BUYER_IMAGE_URL, buyerInfo.getFacebookURL());
        intent.putExtra(Constants.TITLE, title);
        intent.putExtra(Constants.SELLER, seller);
        intent.putExtra(Constants.PRICE, price);
        intent.putExtra(Constants.DISTANCE, distance);
        intent.putExtra(Constants.DESCRIPTION, description);
        intent.putExtra(Constants.PK, pk);
        intent.putExtra(Constants.IMAGE_URLS, imageURLs);

        startActivity(intent);
    }
    
    
}
