package com.bakkle.bakkle.Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.TextView;

import com.bakkle.bakkle.Helpers.ChatMessage;
import com.bakkle.bakkle.R;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 7/31/15.
 */
public class ChatArrayAdapter extends ArrayAdapter<ChatMessage>
{

    private Context context;
    private ArrayList<ChatMessage> chatMessageList = new ArrayList<>();
    private TextView chatText;
    boolean isSelfBuyer;

    private static class ViewHolder
    {
        TextView message;
        Button accept;
        Button reject;
    }

    public ChatArrayAdapter(Context context, int textViewResourceId, boolean isSelfBuyer)
    {
        super(context, textViewResourceId);
        this.context = context;
        this.isSelfBuyer = isSelfBuyer;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent)
    {
        final ChatMessage item = (ChatMessage) getItem(position);
        final ViewHolder viewHolder;
        if (convertView == null) {
            viewHolder = new ViewHolder();

            if (!item.isOffer()) {
                if (item.left)
                    convertView = LayoutInflater.from(getContext()).inflate(R.layout.left_message, parent, false);
                else
                    convertView = LayoutInflater.from(getContext()).inflate(R.layout.right_message, parent, false);

            }
            else if (item.isTextOnly()) {

                convertView = LayoutInflater.from(getContext()).inflate(R.layout.offer_text, parent, false);
            }
            else if (item.isSentByBuyer()) {
                convertView = LayoutInflater.from(getContext()).inflate(R.layout.offer_self_propose, parent, false);
                viewHolder.reject = (Button) convertView.findViewById(R.id.reject_offer);
            }
            else {
                convertView = LayoutInflater.from(getContext()).inflate(R.layout.offer_not_self_propose, parent, false);
                viewHolder.reject = (Button) convertView.findViewById(R.id.reject_offer);
                viewHolder.accept = (Button) convertView.findViewById(R.id.accept_offer);
            }

            viewHolder.message = (TextView) convertView.findViewById(R.id.message_text);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }

        viewHolder.message.setText(getMessageString(item));
        viewHolder.reject.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {

            }
        });
        viewHolder.accept.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {

            }
        });

        return convertView;
    }

    private String getMessageString(ChatMessage item)
    {
//        if (!item.isOffer()) {
//            return item.message;
//        }
//        else if (item.isTextOnly()) {
//
//        }
//        else if (item.isSentByBuyer()) {
//
//        }
//        else {
//
//        }

        return item.message;
    }

    @Override
    public ChatMessage getItem(int position)
    {
        return super.getItem(getCount() - position - 1);
    }

}
