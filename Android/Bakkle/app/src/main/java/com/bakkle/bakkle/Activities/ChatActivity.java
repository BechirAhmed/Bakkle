package com.bakkle.bakkle.Activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.DataSetObserver;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.InputType;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;

import com.bakkle.bakkle.Adapters.ChatArrayAdapter;
import com.bakkle.bakkle.Helpers.ChatCalls;
import com.bakkle.bakkle.Helpers.ChatMessage;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.WebSocket;

import org.json.JSONObject;

import java.util.ArrayList;

public class ChatActivity extends AppCompatActivity
{

    private ChatArrayAdapter chatArrayAdapter;
    private ListView listView;
    private EditText chatText;
    private Button send;
    private boolean left = false;
    private ServerCalls serverCalls;
    private ChatCalls chatCalls;
    private SharedPreferences preferences;
    private int chatId;
    private String offerId;
    private String response;
    private ArrayList<ChatMessage> chatMessages;
    private String messageText;
    protected ChatMessage tempMessage;
    protected String authToken;
    protected String uuid;
    public boolean selfBuyer;
    private String fbUrl;
    private String title;
    private String sellerName;
    private String price;
    private String distance;
    private String description;
    private String pk;
    private ArrayList<String> imageUrls;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);
        Bundle b = getIntent().getExtras();
        chatId = b.getInt("chatId");
        selfBuyer = b.getBoolean("selfBuyer");
        fbUrl = b.getString("url");
        title = b.getString("title");
        sellerName = b.getString("seller");
        price = b.getString("price");
        distance = b.getString("distance");
        description = b.getString("description");
        pk = b.getString("pk");
        imageUrls = b.getStringArrayList("imageUrls");

        send = (Button) findViewById(R.id.send);
        listView = (ListView) findViewById(R.id.list);
        chatText = (EditText) findViewById(R.id.compose);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        final Drawable upArrow = getResources().getDrawable(R.drawable.abc_ic_ab_back_mtrl_am_alpha);
        upArrow.setColorFilter(getResources().getColor(R.color.white), PorterDuff.Mode.SRC_ATOP);
        getSupportActionBar().setHomeAsUpIndicator(upArrow);
        //toolbar.setNavigationIcon(getResources().getDrawable(R.drawable.abc_ic_ab_back_mtrl_am_alpha));
        //toolbar.setLogo();
        toolbar.setNavigationOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                onBackPressed();
            }
        });

        Glide.with(this)
                .load(fbUrl)
                .crossFade()
                .fitCenter()
                .into((ImageView) findViewById(R.id.profilePicture));

        preferences = PreferenceManager.getDefaultSharedPreferences(this);
        authToken = preferences.getString("auth_token", "");
        uuid = preferences.getString("uuid", "");
        chatCalls = new ChatCalls(uuid, authToken.substring(33, 35), authToken, new GetMessagesWebSocketConnectCallback());
        chatArrayAdapter = new ChatArrayAdapter(this, R.layout.right_message, selfBuyer, chatCalls);
        listView.setAdapter(chatArrayAdapter);


        serverCalls = new ServerCalls(this);


        chatMessages = new ArrayList<>();

        chatText.setOnKeyListener(new View.OnKeyListener()
        {
            public boolean onKey(View v, int keyCode, KeyEvent event)
            {
                if ((event.getAction() == KeyEvent.ACTION_DOWN) && (keyCode == KeyEvent.KEYCODE_ENTER)) {
                    return sendChatMessage();
                }
                return false;
            }
        });
        send.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View arg0)
            {
                sendChatMessage();
            }
        });

        listView.setTranscriptMode(AbsListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
        listView.setAdapter(chatArrayAdapter);

        chatArrayAdapter.registerDataSetObserver(new DataSetObserver()
        {
            @Override
            public void onChanged()
            {
                super.onChanged();
                listView.setSelection(chatArrayAdapter.getCount() - 1);
            }
        });

        chatCalls.connect();

    }

    private boolean sendChatMessage()
    {
        messageText = chatText.getText().toString();
        if (!messageText.equals("")) {
            chatCalls.setCallback(new SendMessageWebSocketCallback());
            chatArrayAdapter.add(new ChatMessage(left, messageText));
            chatText.setText("");
        }
        return true;
    }

    public void makeOffer(MenuItem item)
    {
        AlertDialog.Builder alert = new AlertDialog.Builder(this);
        alert.setTitle("Offer Proposal");
        alert.setMessage("Enter a dollar amount to propose an offer");

        // Set an EditText view to get user input
        final EditText input = (EditText) getLayoutInflater().inflate(R.layout.offer_edittext, null);
        input.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);

        alert.setView(input);
        alert.setPositiveButton("Propose",
                new DialogInterface.OnClickListener()
                {
                    public void onClick(DialogInterface dialog, int whichButton)
                    {
                        String price = input.getText().toString();
                        chatCalls.setCallback(new SendOfferWebSocketCallback(price));
                        chatArrayAdapter.add(new ChatMessage(selfBuyer, false, false, price, null));
                    }
                });
        alert.setNegativeButton("Cancel", new DialogInterface.OnClickListener()
        {
            public void onClick(DialogInterface dialog, int whichButton)
            {
                // do nothing
            }
        });
        alert.show();
    }

    public void populateChat()
    {
        JsonParser jsonParser = new JsonParser();
        JsonElement jsonElement = jsonParser.parse(response);
        JsonObject jsonResponse = jsonElement.getAsJsonObject();
        if (jsonResponse == null || jsonResponse.get("success").getAsInt() != 1 || !jsonResponse.has("messages"))
            return;
        JsonArray messages = jsonResponse.get("messages").getAsJsonArray();
        for (JsonElement temp : messages) {
            JsonObject message = temp.getAsJsonObject();
            if (message.get("message").getAsString().equals("")) { //if message field is empty, then it must be an offer
                populateOffer(message.get("offer").getAsJsonObject(), message.get("sent_by_buyer").getAsBoolean());
            }
            else {
                populateMessage(message.get("message").getAsString(), message.get("sent_by_buyer").getAsBoolean());
            }
        }
    }

    public void populateMessage(final String message, final boolean sentByBuyer)
    {
        runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                chatArrayAdapter.add(new ChatMessage(selfBuyer ? !sentByBuyer : sentByBuyer, message));
            }
        });
    }

    public void populateOffer(final JsonObject offer, final boolean sentByBuyer)
    {
        final String status = offer.get("status").getAsString();
        offerId = offer.get("pk").getAsString();
        runOnUiThread(new Runnable()
        {
            public void run()
            {
                chatArrayAdapter.add(new ChatMessage(sentByBuyer, status.equals("Accepted"), status.equals("Retracted"), offer.get("proposed_price").getAsString(), offerId));
            }
        });
    }

    public void viewItem(MenuItem item)
    {
        Intent intent = new Intent(this, ItemDetailActivity.class);
        intent.putExtra("title", title);
        intent.putExtra("seller", sellerName);
        intent.putExtra("price", price);
        intent.putExtra("distance", distance);
        intent.putExtra("sellerImageUrl", fbUrl);
        intent.putExtra("description", description);
        intent.putExtra("pk", pk);
        intent.putExtra("parent", "chat");
        intent.putStringArrayListExtra("imageURLs", imageUrls);
        startActivity(intent);
    }
    private class GetMessagesWebSocketConnectCallback implements AsyncHttpClient.WebSocketConnectCallback
    {

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if (ex != null) {
                Log.v("Callback exception", ex.getMessage());
                return;
            }
            JSONObject json = new JSONObject();
            try {
                json.put("method", "chat_getMessagesForChat");
                json.put("chatId", chatId);
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
                    populateChat();
                }
            });

        }
    }


    private class SendMessageWebSocketCallback implements AsyncHttpClient.WebSocketConnectCallback
    {

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if (ex != null) {
                Log.v("Callback exception", ex.getMessage());
                return;
            }
            JSONObject json = new JSONObject();
            try {
                json.put("method", "chat_sendChatMessage");
                json.put("chatId", chatId);
                json.put("message", messageText);
                json.put("offerPrice", "");
                json.put("offerMethod", "");
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
                }
            });
        }
    }



    private class SendOfferWebSocketCallback implements AsyncHttpClient.WebSocketConnectCallback
    {
        String price;

        public SendOfferWebSocketCallback(String price)
        {
            this.price = price;
        }

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if (ex != null) {
                Log.v("Callback exception", ex.getMessage());
                return;
            }
            JSONObject json = new JSONObject();
            try {
                json.put("method", "chat_sendChatMessage");
                json.put("chatId", chatId);
                json.put("message", "");
                json.put("offerPrice", price);
                json.put("offerMethod", "Meet");
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
                }
            });
        }
    }




    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_chat, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
//        if (id == R.id.action_settings) {
//            return true;
//        }

        return super.onOptionsItemSelected(item);
    }

}
