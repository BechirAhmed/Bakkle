package com.bakkle.bakkle;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.widget.ImageView;

/**
 * Created by vanshgandhi on 6/15/15.
 */
public class StackImageView extends ImageView {

    private int mHeight;
    private int mWidth;
    //private float mRotate;

    public StackImageView(Context context) {
        super(context);
        //initRotate();
    }

    public StackImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        //initRotate();
    }

//    private void initRotate(){
//        mRotate = (new Random().nextFloat() - 0.5f) * 30;
//    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        mWidth = bottom - top;
        mHeight = right - left;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int borderWidth = 2;
        canvas.save();
        //canvas.rotate(mRotate, mWidth / 2, mHeight / 2);
        Paint paint = new Paint();
        paint.setAntiAlias(true);
        paint.setColor(0xffffffff);
        canvas.drawRect(getPaddingLeft() - borderWidth, getPaddingTop() - borderWidth, mWidth - (getPaddingRight() - borderWidth), mHeight - (getPaddingBottom() - borderWidth), paint);
        super.onDraw(canvas);
        canvas.restore();
    }










}
