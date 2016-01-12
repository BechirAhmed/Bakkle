package com.bakkle.bakkle.Chat;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.GetFeedItem;
import com.bakkle.bakkle.Models.Person;
import com.bakkle.bakkle.R;
import com.bakkle.bakkle.Views.CircleImageView;
import com.squareup.picasso.Picasso;

import java.util.List;

public class MessageListAdapter extends RecyclerView.Adapter<MessageListAdapter.ViewHolder>
{

    private final List<MessageListFragment.BuyerAndChatId> buyerAndChatIds;
    private final Context                                  context;

    public MessageListAdapter(List<MessageListFragment.BuyerAndChatId> buyerAndChatIds, Context context)
    {
        this.buyerAndChatIds = buyerAndChatIds;
        this.context = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.message_list_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position)
    {
        holder.buyer = buyerAndChatIds.get(position).buyer;
        holder.chatId = buyerAndChatIds.get(position).chatId;
        holder.nameTextView.setText(holder.buyer.getDisplay_name());
        Picasso.with(context)
                .load(holder.buyer.getAvatar_image_url())
                .fit()
                .centerCrop()
                .into(holder.profilePictureImageView);

        holder.mView.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Intent intent = new Intent(context, ChatActivity.class);
                intent.putExtra(Constants.FEED_ITEM, ((GetFeedItem)context).getItem());
                intent.putExtra(Constants.IS_SELF_SELLER, true);
                intent.putExtra(Constants.CHAT_ID, holder.chatId);
                intent.putExtra(Constants.NAME, holder.buyer.getDisplay_name());
                context.startActivity(intent);
            }
        });
    }

    @Override
    public int getItemCount()
    {
        return buyerAndChatIds != null ? buyerAndChatIds.size() : 0;
    }

    public class ViewHolder extends RecyclerView.ViewHolder
    {
        public final View            mView;
        public final TextView        nameTextView;
        public final CircleImageView profilePictureImageView;
        public       Person          buyer;
        public int chatId;

        public ViewHolder(View view)
        {
            super(view);
            mView = view;
            nameTextView = (TextView) view.findViewById(R.id.name);
            profilePictureImageView = (CircleImageView) view.findViewById(R.id.prof_pic);
        }
    }
}
