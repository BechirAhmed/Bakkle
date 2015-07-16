package com.andtinder.view;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.andtinder.FontFitTextView;
import com.andtinder.R;
import com.andtinder.model.CardModel;
import com.enrique.stackblur.StackBlurManager;

public final class SimpleCardStackAdapter extends CardStackAdapter {

	Context context;

	public SimpleCardStackAdapter(Context mContext) {
		super(mContext);
		context = mContext;
	}

	@Override
	public View getCardView(int position, CardModel model, View convertView, ViewGroup parent) {
		if(convertView == null) {
			LayoutInflater inflater = LayoutInflater.from(getContext());
			convertView = inflater.inflate(R.layout.std_card_inner, parent, false);
			assert convertView != null;
		}

		Drawable image = model.getCardImageDrawable();

		((ImageView) convertView.findViewById(R.id.image)).setImageDrawable(image);
		((de.hdodenhof.circleimageview.CircleImageView) convertView.findViewById(R.id.sellerImage)).setImageDrawable(model.getSellerImageDrawable());
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
}
