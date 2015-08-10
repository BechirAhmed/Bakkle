package com.bakkle.bakkle.Helpers;

import android.util.Log;

import com.koushikdutta.async.ByteBufferList;
import com.koushikdutta.async.DataEmitter;
import com.koushikdutta.async.callback.CompletedCallback;
import com.koushikdutta.async.callback.DataCallback;
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
    AsyncHttpClient client;
    private WebSocket webSocket;

    public ChatCalls(String uuid, String userId, String authToken)
    {
        this.uuid = uuid;
        this.userId = userId;
        this.authToken = authToken;
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
        String url = "ws://bakkle.rhventures.org:8000/ws/?userId=10&uuid=9D223CB7-6438-4699-A9CF-FBF393DD4597";
        client.websocket(url, null, new WebSocketCallBack(this));
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
                chatCalls.setWebSocket(webSocket);
                chatCalls.sendString(json.toString());
                webSocket.setStringCallback(new WebSocket.StringCallback()
                {
                    public void onStringAvailable(String s)
                    {
                        Log.v("testing", s);

                    }
                });
                webSocket.setDataCallback(new DataCallback()
                {
                    @Override
                    public void onDataAvailable(DataEmitter emitter, ByteBufferList bb)
                    {
                        System.out.println("I got some bytes!");
                        bb.recycle();
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
            }
        }
    }

    public void sendString(String string)
    {
        webSocket.send(string);
    }


    public void getChatList()
    {
    }
}
