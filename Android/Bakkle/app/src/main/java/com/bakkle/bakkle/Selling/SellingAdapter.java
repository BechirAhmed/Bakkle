package com.bakkle.bakkle.Selling;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.R;
import com.bakkle.bakkle.Views.CircleImageView;
import com.squareup.picasso.Picasso;

import java.util.List;

public class SellingAdapter extends RecyclerView.Adapter<SellingAdapter.ViewHolder>
{

    private final List<FeedItem> items;
    private final Activity       activity;

    public SellingAdapter(List<FeedItem> items, Activity activity)
    {
        this.items = items;
        this.activity = activity;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.selling_list_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position)
    {
        holder.item = items.get(position);
        holder.titleTextView.setText(holder.item.getTitle());
        holder.priceTextView.setText("$".concat(holder.item.getPrice()));
        holder.totalViewsTextView.setText(String.valueOf(holder.item.getNumViews()));
        holder.wantTextView.setText(String.valueOf(holder.item.getNumWant()));
        holder.holdTextView.setText(String.valueOf(holder.item.getNumHolding()));
        holder.nopeTextView.setText(String.valueOf(holder.item.getNumNope()));

        holder.productImageView.setColorFilter(Color.rgb(123, 123, 123),
                                               android.graphics.PorterDuff.Mode.MULTIPLY);

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
//                Intent intent = new Intent(activity, ItemDetailActivity.class);
//                intent.putExtra(Constants.FEED_ITEM, holder.item);
//                activity.startActivity(intent);
                Intent intent = new Intent(activity, SellingOneItemActivity.class);
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
        public final TextView        totalViewsTextView;
        public final TextView        wantTextView;
        public final TextView        nopeTextView;
        public final TextView        holdTextView;
        public final CircleImageView productImageView;
        public       FeedItem        item;

        public ViewHolder(View view)
        {
            super(view);
            mView = view;
            titleTextView = (TextView) view.findViewById(R.id.title);
            priceTextView = (TextView) view.findViewById(R.id.price);
            productImageView = (CircleImageView) view.findViewById(R.id.product);
            totalViewsTextView = (TextView) view.findViewById(R.id.total_count);
            wantTextView = (TextView) view.findViewById(R.id.want_count);
            nopeTextView = (TextView) view.findViewById(R.id.nope_count);
            holdTextView = (TextView) view.findViewById(R.id.hold_count);
        }
    }
}
