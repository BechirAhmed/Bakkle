package com.bakkle.bakkle;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 7/31/15.
 */
public class ChatArrayAdapter extends ArrayAdapter<ChatMessage> {

    private Context context;
    private ArrayList<ChatMessage> chatMessageList = new ArrayList<>();
    private TextView chatText;

    private static class ViewHolder{
        TextView message;
    }

    public ChatArrayAdapter(Context context, int textViewResourceId) {
        super(context, textViewResourceId);
        this.context = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        final ChatMessage item = (ChatMessage) getItem(position);
        final ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            if(item.left)
                convertView = LayoutInflater.from(getContext()).inflate(R.layout.left_message, parent, false);
            else
                convertView = LayoutInflater.from(getContext()).inflate(R.layout.right_message, parent, false);

            viewHolder.message = (TextView) convertView.findViewById(R.id.message_text);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }

        viewHolder.message.setText(item.message);

        return convertView;
    }

}
