package com.bakkle.bakkle.Chat;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.Models.Person;
import com.bakkle.bakkle.Prefs;
import com.bakkle.bakkle.R;
import com.bakkle.bakkle.Selling.SellingOneItemActivity;
import com.bakkle.bakkle.Views.DividerItemDecoration;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import de.tavendo.autobahn.WebSocketConnection;
import de.tavendo.autobahn.WebSocketException;
import de.tavendo.autobahn.WebSocketHandler;

public class MessageListFragment extends Fragment
{
    final static String ws_base = "ws://app.bakkle.com:8000/ws/";
    Prefs               prefs;
    FeedItem            item;
    List<Person>        buyers;
    RecyclerView        recyclerView;
    String              url;
    WebSocketConnection webSocketConnection;
    SwipeRefreshLayout  listContainer;
    int                 pk;

    public MessageListFragment()
    {
    }

    public static MessageListFragment newInstance()
    {
        return new MessageListFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onAttach(Context context)
    {
        super.onAttach(context);
        item = ((SellingOneItemActivity) context).getItem();
        pk = item.getPk();
        buyers = new ArrayList<>();
        webSocketConnection = new WebSocketConnection();
        prefs = Prefs.getInstance();
        url = ws_base + "?uuid=" + prefs.getUuid() + "&userId=" + prefs.getAuthToken()
                .split("_")[1];
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.recycler_view, container, false);
        recyclerView = (RecyclerView) view.findViewById(R.id.list);
        recyclerView.addItemDecoration(
                new DividerItemDecoration(getContext(), DividerItemDecoration.VERTICAL_LIST));

        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        listContainer = (SwipeRefreshLayout) view.findViewById(R.id.listContainer);

        listContainer.setColorSchemeResources(R.color.colorPrimary, R.color.colorNope,
                                              R.color.colorHoldBlue);

        listContainer.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener()
        {
            @Override
            public void onRefresh()
            {
                getChatList(new GetChatListener());
            }
        });

        getChatList(new GetChatListener());

        return view;
    }

    private List<BuyerAndChatId> processJson(JSONObject jsonObject) throws JSONException
    {
        JSONArray chatArray = jsonObject.getJSONArray("chats");
        List<BuyerAndChatId> buyerAndChatIds = new ArrayList<>();
        for (int i = 0; i < chatArray.length(); i++) {
            JSONObject chatJson = chatArray.getJSONObject(i);
            JSONObject buyerJson = chatJson.getJSONObject("buyer");
            Person buyer = new Person();
            if (buyerJson.getString("display_name").contains("Guest")) {
                continue;
            }
            buyer.setDisplay_name(buyerJson.getString("display_name"));
            buyer.setFacebook_id(buyerJson.getString("facebook_id"));

            buyer.setAvatar_image_url(buyer.getFacebook_id()
                                              .matches(
                                                      "[0-9]+") ? "https://graph.facebook.com/" + buyer
                    .getFacebook_id() + "/picture?type=normal" : null);
            buyer.setPk(buyerJson.getInt("pk"));
            buyer.setUser_location(buyerJson.getString("user_location"));
            buyerAndChatIds.add(new BuyerAndChatId(buyer, chatJson.getInt("pk")));
        }
        return buyerAndChatIds;
    }

    public void getChatList(WebSocketHandler webSocketHandler)
    {
        try {
            if (!webSocketConnection.isConnected()) {
                webSocketConnection.connect(url, webSocketHandler);
            } else {
                makeRequest();
            }
        } catch (WebSocketException e) {
            Toast.makeText(getContext(), "There was an error getting the chat list",
                           Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

    private class GetChatListener extends WebSocketHandler
    {
        @Override
        public void onOpen()
        {
            makeRequest();
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
                    Toast.makeText(getContext(), "There was an error getting the chat list",
                                   Toast.LENGTH_SHORT).show();
                    return;
                } else if (!jsonObject.has("chats")) {
                    return;
                }
                recyclerView.setAdapter(
                        new MessageListAdapter(processJson(jsonObject), getActivity()));
                listContainer.setRefreshing(false);

            } catch (JSONException e) {
                Toast.makeText(getContext(), "There was an error getting the chat list",
                               Toast.LENGTH_SHORT).show();
            }
        }

    }

    private void makeRequest()
    {
        JSONObject json = new JSONObject();
        try {
            json.put("method", "chat_getChatIds");
            json.put("itemId", pk);
            json.put("uuid", prefs.getUuid());
            json.put("auth_token", prefs.getAuthToken());
        } catch (JSONException e) {
            Toast.makeText(getContext(), "There was an error getting the chat list",
                           Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }

        webSocketConnection.sendTextMessage(json.toString());
    }

    public class BuyerAndChatId
    {
        public Person buyer;
        public int    chatId;
        public BuyerAndChatId(Person buyer, int chatId)
        {
            this.buyer = buyer;
            this.chatId = chatId;
        }
    }

}
