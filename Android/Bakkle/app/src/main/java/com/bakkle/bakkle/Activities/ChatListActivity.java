package com.bakkle.bakkle.Activities;

import android.app.ListActivity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;

import com.bakkle.bakkle.Adapters.ChatListAdapter;
import com.bakkle.bakkle.Helpers.BuyerInfo;
import com.bakkle.bakkle.Helpers.ChatCalls;
import com.bakkle.bakkle.R;
import com.google.gson.JsonObject;

import java.util.ArrayList;


public class ChatListActivity extends ListActivity {

    ArrayList<BuyerInfo> buyerInfos = null;
    JsonObject json;
    SharedPreferences preferences;
    ChatCalls chatCalls;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_list);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);

        chatCalls = new ChatCalls(preferences.getString("uuid", ""), preferences.getString("userID", ""), preferences.getString("auth_token", ""));
        chatCalls.connect();
        preferences = PreferenceManager.getDefaultSharedPreferences(this);
        chatCalls.getChatList();
        buyerInfos = new ArrayList<>();
        buyerInfos.add(new BuyerInfo("Vansh", "http://i.imgur.com/RotoKyk.jpg"));
        setListAdapter(new ChatListAdapter(this, buyerInfos));
    }

    private ArrayList<BuyerInfo> getItems(JsonObject json) {

        return null;
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
