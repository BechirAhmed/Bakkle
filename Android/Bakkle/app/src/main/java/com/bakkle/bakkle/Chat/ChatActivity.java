package com.bakkle.bakkle.Chat;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Toast;

import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.ItemDetailActivity;
import com.bakkle.bakkle.Message;
import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.Prefs;
import com.bakkle.bakkle.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import de.tavendo.autobahn.WebSocketConnection;
import de.tavendo.autobahn.WebSocketException;
import de.tavendo.autobahn.WebSocketHandler;

public class ChatActivity extends AppCompatActivity
{
    final static String ws_base = "ws://app.bakkle.com:8000/ws/";

    FeedItem            feedItem;
    Prefs               prefs;
    boolean             isSelfSeller;
    int                 chatId;
    int                 itemId;
    boolean             chatInitiatedAlready;
    String              url;
    WebSocketConnection webSocketConnection;
    RecyclerView        recyclerView;
    ImageButton         sendButton;
    EditText            composeEditText;
    ChatAdapter         chatAdapter;
    List<Message>       messages;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        feedItem = (FeedItem) getIntent().getSerializableExtra(Constants.FEED_ITEM);
        isSelfSeller = getIntent().getBooleanExtra(Constants.IS_SELF_SELLER, true);
        chatId = getIntent().getIntExtra(Constants.CHAT_ID, -1);
        itemId = feedItem.getPk();
        toolbar.setTitle(getIntent().getStringExtra(Constants.NAME));
        setSupportActionBar(toolbar);

        recyclerView = (RecyclerView) findViewById(R.id.chat_recycler_view);
        LinearLayoutManager llm = new LinearLayoutManager(this);
        llm.setReverseLayout(true);
        llm.setStackFromEnd(true);
        recyclerView.setLayoutManager(llm);

        composeEditText = (EditText) findViewById(R.id.compose);

        sendButton = (ImageButton) findViewById(R.id.send);
        sendButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                String text = composeEditText.getText().toString();
                if (!text.isEmpty()) {
                    sendMessage(text);
                }
            }
        });

        webSocketConnection = new WebSocketConnection();
        prefs = Prefs.getInstance();
        url = ws_base + "?uuid=" + prefs.getUuid() + "&userId=" + prefs.getAuthToken()
                .split("_")[1];

        chatInitiatedAlready = chatId != -1;
        getChat(new GetChatListener());

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
    }

    private void sendMessage(String text)
    {
        try {
            if (webSocketConnection.isConnected()) {
                JSONObject json = new JSONObject();
                json.put("method", "chat_sendChatMessage");
                json.put("chatId", Integer.toString(chatId));
                json.put("message", text);
                json.put("offerPrice", ""); //These are required parameters
                json.put("offerMethod", "");
                json.put("uuid", prefs.getUuid());
                json.put("auth_token", prefs.getAuthToken());
                webSocketConnection.sendTextMessage(json.toString());
                if (chatAdapter != null || messages != null) {
                    messages.add(0, new Message(text, "", true)); //TODO: Add a real timestamp
                    chatAdapter.notifyItemInserted(0);
                    composeEditText.setText("");
                }
            } else {
                webSocketConnection.connect(url, new GetChatListener());
            }
        } catch (WebSocketException | JSONException e) {
            Toast.makeText(this, "There was an error sending your message", Toast.LENGTH_SHORT)
                    .show();
            e.printStackTrace();
        }
    }

    public void getChat(WebSocketHandler webSocketHandler)
    {
        try {
            if (!webSocketConnection.isConnected()) {
                webSocketConnection.connect(url, webSocketHandler);
            } else {
                makeChatRequest();
            }
        } catch (WebSocketException e) {
            Toast.makeText(this, "There was an error retrieving messages", Toast.LENGTH_SHORT)
                    .show();
            e.printStackTrace();
        }
    }

    private class GetChatListener extends WebSocketHandler
    {
        @Override
        public void onOpen()
        {
            makeChatRequest();
        }

        @Override
        public void onClose(int code, String reason)
        {

        }

        @Override
        public void onTextMessage(String s)
        {
            try {
                JSONObject jsonObject = new JSONObject(s);
                if (jsonObject.getInt("success") != 1) {
                    Toast.makeText(ChatActivity.this, "There was an error", Toast.LENGTH_SHORT)
                            .show();
                    return;
                } else if (jsonObject.has("chatId")) {
                    chatId = jsonObject.getInt("chatId");
                    chatInitiatedAlready = true;
                    makeChatRequest();
                } else if (jsonObject.has("messages")) {
                    messages = processJson(jsonObject);
                    chatAdapter = new ChatAdapter(messages);
                    recyclerView.setAdapter(chatAdapter);
                } else if (jsonObject.has("message")) {
                    try {
                        if (jsonObject.getString("message").equals("Welcome")) {
                            return;
                        }
                    } catch (JSONException e) {
                        String text = jsonObject.getJSONObject("message").getString("message");
                        messages.add(0, new Message(text, "", false)); //TODO: Add a real timestamp
                        chatAdapter.notifyItemInserted(0);
                    }

                }

            } catch (JSONException e) {
                Toast.makeText(ChatActivity.this, "There was an error retrieving messages",
                               Toast.LENGTH_SHORT).show();
                e.printStackTrace();
            }
        }

    }

    private List<Message> processJson(JSONObject jsonObject) throws JSONException
    {
        JSONArray messagesArray = jsonObject.getJSONArray("messages");
        List<Message> messages = new ArrayList<>();
        for (int i = 0; i < messagesArray.length(); i++) {
            JSONObject messageJson = messagesArray.getJSONObject(i);
            if (messageJson.has("offer")) {
                continue;
            }
            Message message = new Message();
            message.setTimestamp(messageJson.getString("date_sent"));
            message.setText(messageJson.getString("message"));
            message.setSelf(isSelfSeller != messageJson.getBoolean("sent_by_buyer"));
            messages.add(message);
        }
        return messages;
    }

    private void makeChatRequest()
    {
        JSONObject json = new JSONObject();
        try {
            json.put("uuid", prefs.getUuid());
            json.put("auth_token", prefs.getAuthToken());

            if (chatInitiatedAlready) {
                json.put("method", "chat_getMessagesForChat");
                json.put("chatId", chatId);
            } else {
                json.put("method", "chat_startChat");
                json.put("itemId", itemId);
            }
        } catch (JSONException e) {
            Toast.makeText(this, "There was an error retrieving messages", Toast.LENGTH_SHORT)
                    .show();
            e.printStackTrace();
        }

        webSocketConnection.sendTextMessage(json.toString());
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

        if (id == R.id.action_view_item) {
            Intent intent = new Intent(this, ItemDetailActivity.class);
            intent.putExtra(Constants.FEED_ITEM, feedItem);
            intent.putExtra(Constants.SHOW_NOPE, false);
            intent.putExtra(Constants.SHOW_WANT, false);
            startActivity(intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
