package com.bakkle.bakkle.Helpers;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.util.Log;

import com.koushikdutta.async.callback.CompletedCallback;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.WebSocket;

import org.json.JSONObject;

/**
 * Created by vanshgandhi on 8/6/15.
 */
public class ChatCalls extends Service
{
    //    final static String ws_base = "ws://bakkle.rhventures.org:8000/ws/";
    final static String ws_base = "ws://app.bakkle.com:8000/ws/";
    String uuid, userId, authToken;
    String response;
    AsyncHttpClient client;
    private WebSocket webSocket;
    AsyncHttpClient.WebSocketConnectCallback callback;
    private final IBinder mBinder = new LocalBinder();

    public class LocalBinder extends Binder
    {
        ChatCalls getService()
        {
            return ChatCalls.this;
        }
    }

    public ChatCalls(String uuid, String userId, String authToken, AsyncHttpClient.WebSocketConnectCallback callback)
    {
        this.uuid = uuid;
        this.userId = userId;
        this.authToken = authToken;
        this.callback = callback;
        webSocket = null;
        client = AsyncHttpClient.getDefaultInstance();
    }

    public ChatCalls(){}

    public void setWebSocket(WebSocket webSocket)
    {
        this.webSocket = webSocket;
    }

    public void setCallback(AsyncHttpClient.WebSocketConnectCallback callback)
    {
        this.callback = callback;
        connect();
    }

    public void connect()
    {
        String url = ws_base + "?uuid=" + uuid + "&userId=" + userId;
//        String url = "ws://bakkle.rhventures.org:8000/ws/?uuid=E7F742EB-67EE-4738-ABEC-F0A3B62B45EB&userId=10";
        client.websocket(url, null, callback);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent)
    {
        return mBinder;
    }

    @Override
    public int onStartCommand(Intent i, int flags, int startId)
    {
        Log.v("LocalService", "Received start id " + startId + ": " + i);
        uuid = i.getExtras().getString("uuid");
        userId = i.getExtras().getString("sellerPk");
        authToken = i.getExtras().getString("auth_token");

        connect();



        return START_REDELIVER_INTENT;
    }

    @Override
    public void onDestroy()
    {

    }


    @Override
    public void onCreate()
    {

    }


    public class WebSocketCallBack implements AsyncHttpClient.WebSocketConnectCallback
    {
        ChatCalls chatCalls;

        public WebSocketCallBack(ChatCalls chatCalls)
        {
            this.chatCalls = chatCalls;
        }

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if (ex != null) {
                ex.printStackTrace();
                return;
            }

            if (webSocket != null) {
                chatCalls.setWebSocket(webSocket);
                webSocket.setStringCallback(new WebSocket.StringCallback()
                {
                    public void onStringAvailable(String s)
                    {
                        Log.v("testing", s);

                    }
                });

                //idle time out or loss of network connectivity
                webSocket.setClosedCallback(new CompletedCallback()
                {
                    public void onCompleted(Exception ex)
                    {
                        if (ex != null) {
                            ex.printStackTrace();
                        }
                        System.out.println("Socket connection lost, reconnecting");
                        chatCalls.connect();

                    }
                });
                chatCalls.test();
                chatCalls.getChatList();
            }
        }
    }

    public void sendString(String string)
    {
        webSocket.send(string);
    }

    public void test()
    {
        JSONObject json = new JSONObject();
        try {
            json.put("method", "echo");
            json.put("message", "testing the connection");
            json.put("uuid", uuid);
            json.put("auth_token", authToken);
//            json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
//            json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
            Log.v("the json is ", json.toString());
//                    json.put("uuid", uuid);
//                    json.put("auth_token", authToken);
        }
        catch (Exception e) {
        }
        sendString(json.toString());
    }


    public void getChatList()
    {
        JSONObject json = new JSONObject();
        try {
            json.put("method", "chat_getChatIds");
            json.put("itemId", "14");
            json.put("uuid", uuid);
            json.put("auth_token", authToken);
//            json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
//            json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
            Log.v("the json is ", json.toString());
        }
        catch (Exception e) {
        }

        webSocket.setStringCallback(new WebSocket.StringCallback()
        {
            @Override
            public void onStringAvailable(String s)
            {
                response = s;
                Log.v("getChatList ", s);
            }
        });

        sendString(json.toString());

    }
}
