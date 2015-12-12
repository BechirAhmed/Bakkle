package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.List;

public class WatchListAndBuyingAdapter
        extends RecyclerView.Adapter<WatchListAndBuyingAdapter.ViewHolder>
{

    private final List<FeedItem> items;
    private Activity activity;


    public WatchListAndBuyingAdapter(List<FeedItem> items, Activity activity)
    {
        this.items = items;
        this.activity = activity;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.watchlist_trunk_list_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position)
    {
        holder.item = items.get(position);
        holder.titleTextView.setText(holder.item.getTitle());
        holder.priceTextView.setText('$' + holder.item.getPrice());
        holder.productImageView.setImageUrl(holder.item.getImage_urls()[0],
                                            Server.getInstance().getImageLoader());

        holder.mView.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Intent intent = new Intent(activity, ItemDetailActivity.class);
                intent.putExtra(Constants.FEED_ITEM, holder.item);
                activity.startActivity(intent);
            }
        });
    }

    @Override
    public int getItemCount()
    {
        return items != null ? items.size() : 0;
    }

    public class ViewHolder extends RecyclerView.ViewHolder
    {
        public final View            mView;
        public final TextView        titleTextView;
        public final TextView        priceTextView;
        public final CircleImageView productImageView;
        public       FeedItem        item;

        public ViewHolder(View view)
        {
            super(view);
            mView = view;
            titleTextView = (TextView) view.findViewById(R.id.title);
            priceTextView = (TextView) view.findViewById(R.id.price);
            productImageView = (CircleImageView) view.findViewById(R.id.product);
        }
    }
}
