package com.bakkle.bakkle.Helpers;

import android.os.Handler;
import android.util.Log;

import com.koushikdutta.async.callback.CompletedCallback;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.WebSocket;

import org.json.JSONObject;

/**
 * Created by vanshgandhi on 8/6/15.
 */
public class ChatCalls
{
    //    final static String ws_base = "ws://bakkle.rhventures.org/ws/";
    final static String ws_base = "ws://app.bakkle.com/ws/";
    String uuid, userId, authToken;
    String response;
    AsyncHttpClient client;
    private WebSocket webSocket;
    Handler handler;
    Runnable runnable;
    AsyncHttpClient.WebSocketConnectCallback callback;

    public ChatCalls(String uuid, String userId, String authToken, Handler h, Runnable r, AsyncHttpClient.WebSocketConnectCallback callback)
    {
        this.uuid = uuid;
        this.userId = userId;
        this.authToken = authToken;
        this.handler = h;
        this.runnable = r;
        this.callback = callback;
        webSocket = null;
        client = AsyncHttpClient.getDefaultInstance();
    }

    public void setWebSocket(WebSocket webSocket)
    {
        this.webSocket = webSocket;
    }

    public void connect()
    {
//        String url = ws_base + "?uuid=" + uuid + "&userId=" + userId;
        String url = "ws://bakkle.rhventures.org:8000/ws/?uuid=E7F742EB-67EE-4738-ABEC-F0A3B62B45EB&userId=10";
        client.websocket(url, null, callback);
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

                handler.post(runnable);

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
            json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
            json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
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
            json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
            json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
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
