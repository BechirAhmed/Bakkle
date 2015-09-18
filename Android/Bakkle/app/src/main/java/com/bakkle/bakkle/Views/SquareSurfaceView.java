package com.bakkle.bakkle.Views;

/**
 * Created by vanshgandhi on 9/1/15.
 */

import android.content.Context;
import android.util.AttributeSet;
import android.view.SurfaceView;

public class SquareSurfaceView extends SurfaceView
{


    public SquareSurfaceView(Context context)
    {
        super(context);
    }

    public SquareSurfaceView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
    }

    public SquareSurfaceView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        super.onMeasure(widthMeasureSpec, widthMeasureSpec);
    }
}