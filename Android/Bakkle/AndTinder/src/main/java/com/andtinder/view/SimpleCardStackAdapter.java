package com.andtinder.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.andtinder.CircleImageView;
import com.andtinder.R;
import com.andtinder.model.CardModel;

public final class SimpleCardStackAdapter extends CardStackAdapter {

	public SimpleCardStackAdapter(Context mContext) {
		super(mContext);
	}

	@Override
	public View getCardView(int position, CardModel model, View convertView, ViewGroup parent) {
		if(convertView == null) {
			LayoutInflater inflater = LayoutInflater.from(getContext());
			convertView = inflater.inflate(R.layout.std_card_inner, parent, false);
			assert convertView != null;
		}

		((ImageView) convertView.findViewById(R.id.image)).setImageDrawable(model.getCardImageDrawable());
		((CircleImageView) convertView.findViewById(R.id.sellerImage)).setImageDrawable(model.getSellerImageDrawable());
		((TextView) convertView.findViewById(R.id.title)).setText(model.getTitle());
		((TextView) convertView.findViewById(R.id.seller)).setText(model.getSeller());
		((TextView) convertView.findViewById(R.id.price)).setText(model.getPrice());
		((TextView) convertView.findViewById(R.id.location)).setText(model.getDistance());
		((TextView) convertView.findViewById(R.id.method)).setText(model.getMethod());

		return convertView;
	}
}
