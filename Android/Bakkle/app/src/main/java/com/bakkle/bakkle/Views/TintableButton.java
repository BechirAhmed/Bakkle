package com.bakkle.bakkle.Views;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ImageView;

/**
 * Created by vanshgandhi on 9/4/15.
 */
public class TintableButton extends ImageView
{

    private boolean mIsSelected;

    public TintableButton(Context context) {
        super(context);
    }

    public TintableButton(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public TintableButton(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    private void init() {
        mIsSelected = false;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN && !mIsSelected) {
            setColorFilter(0x99000000);
            mIsSelected = true;
        } else if ((event.getAction() == MotionEvent.ACTION_UP || event.getAction() == MotionEvent.ACTION_CANCEL) && mIsSelected) {
            setColorFilter(Color.TRANSPARENT);
            mIsSelected = false;
        }

        return super.onTouchEvent(event);
    }
}