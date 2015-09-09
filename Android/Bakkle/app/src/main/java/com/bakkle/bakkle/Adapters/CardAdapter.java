package com.bakkle.bakkle.Adapters;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;

/**
 * Created by vanshgandhi on 7/1/15.
 */
public class CardAdapter extends ArrayAdapter<FeedItem> {

    Context context;
    FeedItem item;

    public CardAdapter(Context c){
        super(c, R.layout.card_layout);
        context = c;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        if(convertView == null) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            convertView = inflater.inflate(R.layout.card_layout, parent, false);
            assert convertView != null;
        }
        item = getItem(position);
        //Bitmap firstImage = getItem(position).getFirstImage();
//        Bitmap blurredImage = BlurDarken.apply(context, firstImage);
//        Drawable blurred = new BitmapDrawable(blurredImage).getCurrent();

//        ((RelativeLayout) convertView.findViewById(R.id.topBar)).setBackground(blurred);
        convertView.findViewById(R.id.topBar).getBackground().setColorFilter(Color.parseColor("#000000"), PorterDuff.Mode.DARKEN);
//        ((RelativeLayout) convertView.findViewById(R.id.bottomBar)).setBackground(blurred);
        convertView.findViewById(R.id.bottomBar).getBackground().setColorFilter(Color.parseColor("#000000"), PorterDuff.Mode.DARKEN);

//        ((ImageView) convertView.findViewById(com.andtinder.R.id.image)).setImageBitmap(firstImage);
//        ((CircleImageView) convertView.findViewById(com.andtinder.R.id.sellerImage)).setImageBitmap(getItem(position).getSellerImage());
//        ((TextView) convertView.findViewById(com.andtinder.R.id.title)).setText(getItem(position).getTitle());
//        ((TextView) convertView.findViewById(com.andtinder.R.id.seller)).setText(getItem(position).getSellerDisplayName());
        ((TextView) convertView.findViewById(com.andtinder.R.id.price)).setText("$" + getItem(position).getPrice());



        //((ImageView) convertView.findViewById(com.bakkle.bakkle.R.id.image)).setImageBitmap(firstImage);
        Glide.with(context)
                .load(item.getImageUrls().get(0))
                .crossFade()
                .placeholder(R.drawable.loading)
                .into((ImageView) convertView.findViewById(com.bakkle.bakkle.R.id.image));

        Glide.with(context)
                .load("http://graph.facebook.com/" + item.getSellerFacebookId() + "/picture?width=142&height=142")
                .crossFade()
                .into((ImageView) convertView.findViewById(com.bakkle.bakkle.R.id.sellerImage));

        ((TextView) convertView.findViewById(com.bakkle.bakkle.R.id.title)).setText(getItem(position).getTitle());
        ((TextView) convertView.findViewById(com.bakkle.bakkle.R.id.seller)).setText(getItem(position).getSellerDisplayName());
//        ((TextView) convertView.findViewById(com.bakkle.bakkle.R.id.price)).setText("$" + getItem(position).getPrice());

        return convertView;
    }
}
