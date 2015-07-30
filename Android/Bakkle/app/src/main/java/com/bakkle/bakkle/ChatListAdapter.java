package com.bakkle.bakkle;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 7/30/15.
 */
public class ChatListAdapter extends ArrayAdapter<BuyerInfo> {

    ArrayList<BuyerInfo> items;
    Context c;
    AsyncImageLoader asyncImageLoader;


    public ChatListAdapter(Context context, ArrayList<BuyerInfo> objects) {
        super(context, R.layout.chat_list_item, objects);
        items = objects;
        c = context;
        asyncImageLoader = new AsyncImageLoader(context);
    }

    public static class ViewHolder{

        TextView nameText;
        ImageView picture;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){

        final BuyerInfo item = getItem(position);
        final ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.chat_list_item, parent, false);
            viewHolder.picture = (ImageView) convertView.findViewById(R.id.icon);
            viewHolder.nameText = (TextView) convertView.findViewById(R.id.title);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }

        Drawable cachedImage = asyncImageLoader.loadDrawable(item.getFacebookURL(), new AsyncImageLoader.ImageCallback() {
            public void imageLoaded(Drawable imageDrawable, String imageUrl) {
                viewHolder.picture.setImageDrawable(imageDrawable);
            }
        });
        //viewHolder.picture.setImageDrawable(cachedImage);
        viewHolder.nameText.setText(item.getName());

        return convertView;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }
}
