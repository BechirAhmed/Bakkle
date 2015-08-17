package com.bakkle.bakkle.Activities;

import android.content.SharedPreferences;
import android.database.DataSetObserver;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import com.bakkle.bakkle.Adapters.ChatArrayAdapter;
import com.bakkle.bakkle.Helpers.ChatCalls;
import com.bakkle.bakkle.Helpers.ChatMessage;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
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
    private String response;
    private ArrayList<ChatMessage> chatMessages;
    private String messageText;
    protected ChatMessage tempMessage;



    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        chatId = getIntent().getExtras().getInt("chatId");
        send = (Button) findViewById(R.id.send);
        listView = (ListView) findViewById(R.id.list);
        chatText = (EditText) findViewById(R.id.compose);

        chatArrayAdapter = new ChatArrayAdapter(this, R.layout.right_message);
        listView.setAdapter(chatArrayAdapter);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);
        chatCalls = new ChatCalls(preferences.getString("uuid", ""), preferences.getString("auth_token", "").substring(33, 35),
                preferences.getString("auth_token", ""), new GetMessagesWebSocketConnectCallback());


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
            left = !left;
        }
        return true;
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
            Log.v("temp value", temp.toString());
            JsonObject message = temp.getAsJsonObject();
            if (message.get("message").getAsString().equals("")) { //if message field is empty, then it must be an offer
                populateOffer(message.get("offer").getAsJsonObject(), message.get("sent_by_buyer").getAsBoolean());
            }
            else {
                populateMessage(message.get("message").getAsString(), message.get("sent_by_buyer").getAsBoolean());
            }
        }


//        runOnUiThread(new Runnable()
//        {
//            @Override
//            public void run()
//            {
//                chatArrayAdapter.notifyDataSetChanged();
//            }
//        });
    }

    public void populateMessage(final String message, final boolean sentByBuyer)
    {
        //tempMessage = new ChatMessage(!sentByBuyer, message);
        //chatMessages.add(tempMessage);
        Log.v("Before UI thread", message);
        runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                Log.v("ChatMessage is", message);
                chatArrayAdapter.add(new ChatMessage(!sentByBuyer, message));
            }
        });
    }

    public void populateOffer(JsonObject offer, boolean sentByBuyer)
    {

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
                //json.put("chatId", String.valueOf(chatId)); //TODO:add into production code
                json.put("chatId", 58);
                json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
                json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
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
                    Log.v("response is ", "" + response);
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
                //json.put("chatId", String.valueOf(chatId)); //TODO:add into production code
                json.put("chatId", 58);
                json.put("message", messageText);
                json.put("offerPrice", "");
                json.put("offerMethod", "");
                json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
                json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
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
                    Log.v("send string", response);
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
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

}
