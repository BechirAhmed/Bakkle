package com.bakkle.bakkle;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bakkle.bakkle.Models.FeedItem;
import com.squareup.picasso.Picasso;

import java.util.List;

public class FeedAdapter extends ArrayAdapter<FeedItem>
{
    List<FeedItem> items;
    int            resource;
    Context        context;

    public FeedAdapter(Context context, int resource, List<FeedItem> items)
    {
        super(context, resource, items);
        this.items = items;
        this.resource = resource;
        this.context = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent)
    {
        ViewHolder holder;

        if (convertView == null) {
            if (context instanceof MainActivity) {
                convertView = ((MainActivity) context).getLayoutInflater()
                        .inflate(resource, parent, false);
            } else {
                convertView = LayoutInflater.from(context).inflate(resource, parent, false);
            }
            holder = new ViewHolder();
            holder.product = (ImageView) convertView.findViewById(R.id.image);
            holder.title = (TextView) convertView.findViewById(R.id.title);
            holder.price = (TextView) convertView.findViewById(R.id.price);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        FeedItem item = items.get(position);
        String priceText = item.getPrice().equals("0.00") ? "Offer" : "$".concat(item.getPrice());
        holder.price.setText(priceText);
        holder.title.setText(item.getTitle());

        Picasso.with(getContext())
                .load(item.getImage_urls()[0])
                .centerCrop()
                .fit()
                .into(holder.product);
        return convertView;
    }

    static class ViewHolder
    {
        TextView  title;
        TextView  price;
        ImageView product;
    }
}
