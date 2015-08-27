package com.andtinder.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.andtinder.FontFitTextView;
import com.andtinder.R;
import com.andtinder.model.CardModel;
import com.bumptech.glide.Glide;

public final class SimpleCardStackAdapter extends CardStackAdapter
{

    Context context;

    public SimpleCardStackAdapter(Context mContext)
    {
        super(mContext);
        context = mContext;
    }

    @Override
    public View getCardView(int position, CardModel model, View convertView, ViewGroup parent)
    {
        if (convertView == null) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            convertView = inflater.inflate(R.layout.std_card_inner, parent, false);
            assert convertView != null;
        }

        //Drawable image = model.getCardImageDrawable();

        setCardImage((ImageView) (convertView.findViewById(R.id.image)), model.getCardImageURL());
        //setCardImage((ImageView) (convertView.findViewById(R.id.sellerImage)), model.getSellerImageURL());

        //((ImageView) convertView.findViewById(R.id.image)).setImageDrawable(model.getCardImageDrawable());

        setSellerImage((ImageView) convertView.findViewById(R.id.sellerImage), model.getSellerImageURL());

        //((de.hdodenhof.circleimageview.CircleImageView) convertView.findViewById(R.id.sellerImage)).setImageDrawable(model.getSellerImageDrawable());
        //((de.hdodenhof.circleimageview.CircleImageView) convertView.findViewById(R.id.sellerImage)).setImageResource(R.drawable.loading);
        ((FontFitTextView) convertView.findViewById(R.id.title)).setText(model.getTitle());
        ((TextView) convertView.findViewById(R.id.seller)).setText(model.getSeller());
        ((TextView) convertView.findViewById(R.id.price)).setText(model.getPrice());


//		StackBlurManager stackBlurManager = new StackBlurManager(model.cardImageBitmap);
//		stackBlurManager.processRenderScript(context, 23);
//
//		RelativeLayout relativeLayout = (RelativeLayout) convertView.findViewById(R.id.topBar);
//		relativeLayout.setBackground(new BitmapDrawable(context.getResources(), stackBlurManager.returnBlurredImage()));

        return convertView;
    }

    public void setCardImage(ImageView imageView, String url)
    {
        Glide.with(context)
                .load(url)
                .centerCrop()
                .crossFade()
                .placeholder(R.drawable.loading)
                .into(imageView);
    }

    public void setSellerImage(ImageView imageView, String url)
    {
        Glide.with(context)
                .load(url)
                .centerCrop()
                .crossFade()
                .into(imageView);
    }
}
