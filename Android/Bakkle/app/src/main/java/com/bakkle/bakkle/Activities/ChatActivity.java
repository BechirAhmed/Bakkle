package com.bakkle.bakkle.Activities;

import android.content.SharedPreferences;
import android.database.DataSetObserver;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import com.bakkle.bakkle.Adapters.ChatArrayAdapter;
import com.bakkle.bakkle.Helpers.ChatMessage;
import com.bakkle.bakkle.R;
import com.bakkle.bakkle.Helpers.ServerCalls;

public class ChatActivity extends AppCompatActivity
{

    private ChatArrayAdapter chatArrayAdapter;
    private ListView listView;
    private EditText chatText;
    private Button send;
    private boolean left = false;
    private String id;
    private ServerCalls serverCalls;
    private SharedPreferences preferences;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);
        send = (Button) findViewById(R.id.send);
        listView = (ListView) findViewById(R.id.list);
        chatArrayAdapter = new ChatArrayAdapter(this, R.layout.right_message);
        listView.setAdapter(chatArrayAdapter);
        chatText = (EditText) findViewById(R.id.compose);
        id = getIntent().getExtras().getString("id");
        serverCalls = new ServerCalls(this);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);

        getPreviousMessages();

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
    }

    private void getPreviousMessages()
    {

    }

    private boolean sendChatMessage()
    {
        String text = chatText.getText().toString();
        if (text.equals("")) {
            serverCalls.sendChat(preferences.getString("uuid", "0"), preferences.getString("auth_token", "0"), chatText.getText().toString(), id);
            chatArrayAdapter.add(new ChatMessage(left, text));
            chatText.setText("");
            left = !left;
        }
        return true;
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
