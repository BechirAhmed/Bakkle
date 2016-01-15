package com.bakkle.bakkle.Chat;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bakkle.bakkle.R;

import java.util.List;

public class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.ViewHolder>
{

    private final List<Message> messages;

    public ChatAdapter(List<Message> messages)
    {
        this.messages = messages;
    }

    @Override
    public int getItemViewType(int position)
    {
        return messages.get(position).isSelf() ? 0 : 1;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
        View view = null;
        switch (viewType) {
            case 0:
                view = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.chat_bubble_self, parent, false);
                break;
            case 1:
                view = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.chat_bubble_other, parent, false);
        }
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position)
    {
        holder.message = messages.get(position);
        holder.messageTextView.setText(holder.message.getText());
        holder.timestampTextView.setText(holder.message.getNiceTimestamp());
    }

    @Override
    public int getItemCount()
    {
        return messages != null ? messages.size() : 0;
    }

    public class ViewHolder extends RecyclerView.ViewHolder
    {
        public final TextView messageTextView;
        public final TextView timestampTextView;
        public       Message  message;

        public ViewHolder(View view)
        {
            super(view);
            messageTextView = (TextView) view.findViewById(R.id.message);
            timestampTextView = (TextView) view.findViewById(R.id.timestamp);
        }
    }
}
