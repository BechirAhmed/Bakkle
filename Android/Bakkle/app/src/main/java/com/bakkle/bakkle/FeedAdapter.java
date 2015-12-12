package com.bakkle.bakkle;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.NetworkImageView;

import java.util.List;

/**
 * Created by vanshgandhi on 12/5/15.
 */
public class FeedAdapter extends ArrayAdapter<FeedItem>
{
    List<FeedItem> items;
    Context        context;
    int            resource;

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
            convertView = LayoutInflater.from(context).inflate(resource, parent, false);
            holder = new ViewHolder();
            holder.avatar   = (NetworkImageView) convertView.findViewById(R.id.avatar);
            holder.product  = (NetworkImageView) convertView.findViewById(R.id.image);
            holder.title    = (TextView)         convertView.findViewById(R.id.title);
            holder.seller   = (TextView)         convertView.findViewById(R.id.seller);
            holder.price    = (TextView)         convertView.findViewById(R.id.price);
        }
        else {
            holder = (ViewHolder) convertView.getTag();
        }
        ImageLoader imageLoader = Server.getInstance().getImageLoader();
        FeedItem item = items.get(position);
        holder.price.setText("$" + item.getPrice());
        holder.seller.setText(item.getSeller().getDisplay_name());
        holder.title.setText(item.getTitle());
//        holder.product.setDefaultImageResId(R.drawable.ic_wallpaper);
//        holder.product.setErrorImageResId(R.drawable.ic_error);
        holder.product.setImageUrl(item.getImage_urls()[0], imageLoader);
        holder.avatar.setDefaultImageResId(R.drawable.ic_account_circle);
        holder.avatar.setImageUrl("http://graph.facebook.com/" + item.getSeller().getFacebook_id() + "/picture?type=normal", imageLoader);

        return convertView;
    }


    static class ViewHolder
    {
        TextView  title;
        TextView  seller;
        TextView  price;
        NetworkImageView avatar;
        NetworkImageView product;
    }
}
