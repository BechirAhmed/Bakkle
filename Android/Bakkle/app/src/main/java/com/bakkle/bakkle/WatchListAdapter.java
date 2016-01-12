package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.Views.CircleImageView;
import com.squareup.picasso.Picasso;

import java.util.List;

public class WatchListAdapter extends RecyclerView.Adapter<WatchListAdapter.ViewHolder>
{

    private final List<FeedItem> items;
    private       Activity       activity;
    private WatchListFragment fragment;

    public WatchListAdapter(List<FeedItem> items, Activity activity, WatchListFragment fragment)
    {
        this.items = items;
        this.activity = activity;
        this.fragment = fragment;
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
        holder.priceTextView.setText("$".concat(holder.item.getPrice()));

        Picasso.with(activity)
                .load(holder.item.getImage_urls()[0])
                .fit()
                .centerCrop()
                .into(holder.productImageView);

        holder.mView.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Intent intent = new Intent(activity, ItemDetailActivity.class);
                intent.putExtra(Constants.FEED_ITEM, holder.item);
                intent.putExtra(Constants.SHOW_NOPE, true);
                intent.putExtra(Constants.SHOW_WANT, true);
                intent.putExtra(Constants.POSITION, holder.getAdapterPosition());
                fragment.startActivityForResult(intent, Constants.REQUEST_CODE_VIEW_ITEM);
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
