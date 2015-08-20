package com.bakkle.bakkle.Activities;

import android.app.ListActivity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;

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


public class ChatListActivity extends ListActivity
{

    ArrayList<BuyerInfo> buyerInfos = null;
    JsonObject json;
    SharedPreferences preferences;
    ChatCalls chatCalls;
    ChatListAdapter chatListAdapter;
    String response;
    protected String authToken;
    String uuid;
    String itemId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_list);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);
        uuid = preferences.getString("uuid", "");
        authToken = preferences.getString("auth_token", "");

        buyerInfos = new ArrayList<>();
        chatListAdapter = new ChatListAdapter(this, buyerInfos);
        setListAdapter(chatListAdapter);

        preferences = PreferenceManager.getDefaultSharedPreferences(ChatListActivity.this);

//        Intent i = new Intent(this, ChatCalls.class);
//        i.putExtra("uuid", preferences.getString("uuid", ""));
//        i.putExtra("auth_token", authToken);
//        i.putExtra("sellerPk", authToken.substring(33, 35));
//        startService(i);

        itemId = getIntent().getExtras().getString("itemId");

        chatCalls = new ChatCalls(uuid, authToken.substring(33, 35), authToken, new WebSocketCallBack());
        chatCalls.connect();
//        chatCalls.test();
//        chatCalls.getChatList();

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
//                json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
//                json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
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
        runOnUiThread(new Runnable()
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
        Intent intent = new Intent(this, ChatActivity.class);
//        intent.putExtra("chatId", 58);
        intent.putExtra("chatId", buyerInfo.getChatPk()); //make sure to let the chat app window know if youre the buyer or seller somehow
        intent.putExtra("selfBuyer", false);
        intent.putExtra("url", buyerInfo.getFacebookURL());
        startActivity(intent);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_chat_list, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
