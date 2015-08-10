package com.bakkle.bakkle.Activities;

import android.app.ListActivity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_list);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);

        Handler h = new Handler(getMainLooper());
        Runnable r = new Runnable()
        {
            @Override
            public void run()
            {
                Log.v("testing this", "test 123 123");
            }
        };

        buyerInfos = new ArrayList<>();
        chatListAdapter = new ChatListAdapter(this, buyerInfos);
        setListAdapter(chatListAdapter);


        preferences = PreferenceManager.getDefaultSharedPreferences(ChatListActivity.this);
        chatCalls = new ChatCalls(preferences.getString("uuid", ""), preferences.getString("sellerPk", ""), preferences.getString("auth_token", ""), h, r, new WebSocketCallBack());
        chatCalls.connect();
//        chatCalls.test();
//        Log.v("the url is:", "ws://app.bakkle.com/ws/" + "?uuid=" + preferences.getString("uuid", "") + "&userId=" + preferences.getString("sellerPk", ""));
//        chatCalls.getChatList();

    }


    private class WebSocketCallBack implements AsyncHttpClient.WebSocketConnectCallback
    {

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            JSONObject json = new JSONObject();
            try {
                json.put("method", "chat_getChatIds");
                json.put("itemId", "14");
                json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
                json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
                Log.v("the json is ", json.toString());
            }
            catch (Exception e) {
            }

            webSocket.send(json.toString());
            webSocket.setStringCallback(new WebSocket.StringCallback()
            {
                @Override
                public void onStringAvailable(String s)
                {
                    populateList(s);
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
            String url = "https://graph.facebook.com/"+ buyer.get("facebook_id").getAsString() +"/picture?width=142&height=142";
            buyerInfos.add(new BuyerInfo(buyer.get("display_name").getAsString(), url));
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
        intent.putExtra("some form of id", "0"); //make sure to let the chat app window know if youre the buyer or seller somehow
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
