package com.bakkle.bakkle.Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

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
        final ChatMessage item = getItem(position);
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
            else if (item.isSentByBuyer() == isSelfBuyer) {
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

        if (viewHolder.reject != null) {
            viewHolder.reject.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View view)
                {
                    Toast.makeText(context, "Reject", Toast.LENGTH_SHORT).show();
                }
            });
        }
        if (viewHolder.accept != null) {
            viewHolder.accept.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View view)
                {
                    Toast.makeText(context, "Accept", Toast.LENGTH_SHORT).show();
                }
            });
        }

        return convertView;
    }

    private String getMessageString(ChatMessage item)
    {
        if (!item.isOffer()) {
            return item.message;
        }
        else if (item.isTextOnly()) {
            if (item.isSentByBuyer() == isSelfBuyer && item.isRejected())
                return "Your offer of $" + item.getPrice() + " was rejected";
            else if (item.isSentByBuyer() == isSelfBuyer && item.isAccepted())
                return "Your offer of $" + item.getPrice() + " was accepted";
            else if (item.isRejected())
                return "You rejected an offer of $" + item.getPrice();
            else
                return "You accepted an offer of $" + item.getPrice();
        }
        else if (item.isSentByBuyer() == isSelfBuyer) {
            return "You proposed an offer of $" + item.getPrice();
        }
        else {
            return "An offer of $" + item.getPrice() + " has been made";
        }
    }

    @Override
    public ChatMessage getItem(int position)
    {
        return super.getItem(getCount() - position - 1);
    }

}
