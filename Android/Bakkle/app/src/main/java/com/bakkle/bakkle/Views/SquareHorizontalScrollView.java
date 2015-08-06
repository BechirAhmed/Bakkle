package com.bakkle.bakkle.Views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.HorizontalScrollView;

/**
 * Created by vanshgandhi on 7/27/15.
 */
public class SquareHorizontalScrollView extends HorizontalScrollView {


    public SquareHorizontalScrollView(Context context) {
        super(context);
    }

    public SquareHorizontalScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public SquareHorizontalScrollView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, widthMeasureSpec);
    }
}
