package com.andtinder;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.DecelerateInterpolator;
import android.widget.ImageView;

/**
 * Created by vanshgandhi on 6/30/15.
 */
public class OverlayView extends ImageView
{

    Context context;
    Animation inAnimation;
    Animation outAnimation;

    public OverlayView(Context context)
    {
        super(context);
        this.context = context;
        initAnimations();
    }

    public OverlayView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        this.context = context;
        initAnimations();
    }

    public OverlayView(Context context, AttributeSet attrs, int defStyle)
    {
        super(context, attrs, defStyle);
        this.context = context;
        initAnimations();
    }

    private void initAnimations()
    {
        inAnimation = new AlphaAnimation(0, 1);
        inAnimation.setInterpolator(new DecelerateInterpolator());
        inAnimation.setDuration(1);
        outAnimation = new AlphaAnimation(1, 0);
        outAnimation.setInterpolator(new DecelerateInterpolator());
        outAnimation.setDuration(2);
    }

    public void show()
    {
        if (isVisible()) return;
        show(true);
    }

    public void show(boolean withAnimation)
    {
        if (withAnimation)
            this.startAnimation(inAnimation);
        this.setVisibility(View.VISIBLE);
    }

    public void hide()
    {
        if (!isVisible()) return;
        hide(true);
    }

    public void hide(boolean withAnimation)
    {
        if (withAnimation)
            this.startAnimation(outAnimation);
        this.setVisibility(View.GONE);
    }

    public boolean isVisible()
    {
        return (this.getVisibility() == View.VISIBLE);
    }

    public void overrideDefaultInAnimation(Animation inAnimation)
    {
        this.inAnimation = inAnimation;
    }

    public void overrideDefaultOutAnimation(Animation outAnimation)
    {
        this.outAnimation = outAnimation;
    }
}
