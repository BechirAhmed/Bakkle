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
    Activity mActivity;
    String uuid;

    public static ChatListFragment newInstance(String itemId)
    {
        ChatListFragment fragment = new ChatListFragment();
        Bundle args = new Bundle();
        args.putString("itemId", itemId);
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
        if (getArguments() != null) {
            itemId = getArguments().getString("itemId");
        }
        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);
        uuid = preferences.getString("uuid", "");
        authToken = preferences.getString("auth_token", "");

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
        return inflater.inflate(R.layout.fragment_chat_list, null, false);
    }


    private class WebSocketCallBack implements AsyncHttpClient.WebSocketConnectCallback
    {

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if(ex != null)
            {
                Log.v("callback exception", ex.getMessage());
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
//        intent.putExtra("chatId", 58);
        intent.putExtra("chatId", buyerInfo.getChatPk()); //make sure to let the chat app window know if youre the buyer or seller somehow
        intent.putExtra("selfBuyer", false);
        intent.putExtra("url", buyerInfo.getFacebookURL());
        startActivity(intent);
    }
    
    
}
