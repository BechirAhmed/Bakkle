package com.andtinder.view;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.animation.ValueAnimator;
import android.content.Context;
import android.content.res.TypedArray;
import android.database.DataSetObserver;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.view.DragEvent;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.LinearInterpolator;
import android.widget.AdapterView;
import android.widget.ListAdapter;

import com.andtinder.R;
import com.andtinder.model.CardModel;
import com.andtinder.model.Orientations.Orientation;

import java.util.Random;

public class CardContainer extends AdapterView<ListAdapter> implements View.OnDragListener
{
    public static final  int             INVALID_POINTER_ID              = -1;
    private              int             mActivePointerId                = INVALID_POINTER_ID;
    private static final double          DISORDERED_MAX_ROTATION_RADIANS = Math.PI / 64;
    private              int             mNumberOfCards                  = -1;
    private final        DataSetObserver mDataSetObserver                = new DataSetObserver()
    {
        @Override
        public void onChanged()
        {
            super.onChanged();
            clearStack();
            ensureFull();
        }

        @Override
        public void onInvalidated()
        {
            super.onInvalidated();
            clearStack();
        }
    };
    private final        Random          mRandom                         = new Random();
    private final        Rect            boundsRect                      = new Rect();
    private final        Rect            childRect                       = new Rect();
    private final        Matrix          mMatrix                         = new Matrix();


    //TODO: determine max dynamically based on device speed
    private int mMaxVisible = 3;
    private GestureDetector mGestureDetector;
    private int             mFlingSlop;
    private Orientation     mOrientation;
    private ListAdapter     mListAdapter;
    private float           mLastTouchX;
    private float           mLastTouchY;
    private View            mTopCard;
    private int             mTouchSlop;
    private int             mGravity;
    private int             mNextAdapterPosition;
    private boolean         mDragging;

    public CardContainer(Context context)
    {
        super(context);

        setOrientation(Orientation.Ordered);
        setGravity(Gravity.CENTER);
        init();

    }

    public CardContainer(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        initFromXml(attrs);
        init();
    }


    public CardContainer(Context context, AttributeSet attrs, int defStyle)
    {
        super(context, attrs, defStyle);
        initFromXml(attrs);
        init();
    }

    private void init()
    {
        ViewConfiguration viewConfiguration = ViewConfiguration.get(getContext());
        mFlingSlop = viewConfiguration.getScaledMinimumFlingVelocity();
        mTouchSlop = viewConfiguration.getScaledTouchSlop();
        mGestureDetector = new GestureDetector(getContext(), new GestureListener());
    }

    private void initFromXml(AttributeSet attr)
    {
        TypedArray a = getContext().obtainStyledAttributes(attr,
                R.styleable.CardContainer);

        setGravity(a.getInteger(R.styleable.CardContainer_android_gravity, Gravity.CENTER));
        int orientation = a.getInteger(R.styleable.CardContainer_orientation, 1);
        setOrientation(Orientation.fromIndex(orientation));

        a.recycle();
    }

    @Override
    public ListAdapter getAdapter()
    {
        return mListAdapter;
    }

    @Override
    public void setAdapter(ListAdapter adapter)
    {
        if (mListAdapter != null)
            mListAdapter.unregisterDataSetObserver(mDataSetObserver);

        clearStack();
        mTopCard = null;
        mListAdapter = adapter;
        mNextAdapterPosition = 0;
        adapter.registerDataSetObserver(mDataSetObserver);

        ensureFull();

        if (getChildCount() != 0) {
            mTopCard = getChildAt(getChildCount() - 1);
            mTopCard.setLayerType(LAYER_TYPE_HARDWARE, null);
        }
        mNumberOfCards = getAdapter().getCount();
        requestLayout();
    }

    private void ensureFull()
    {
        while (mNextAdapterPosition < mListAdapter.getCount() && getChildCount() < mMaxVisible) {
            View view = mListAdapter.getView(mNextAdapterPosition, null, this);
            view.setLayerType(LAYER_TYPE_SOFTWARE, null);
            if (mOrientation == Orientation.Disordered) {
                view.setRotation(getDisorderedRotation());
            }
            addViewInLayout(view, 0, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT,
                    mListAdapter.getItemViewType(mNextAdapterPosition)), false);

            requestLayout();

            mNextAdapterPosition += 1;
        }
    }

    private void clearStack()
    {
        removeAllViewsInLayout();
        mNextAdapterPosition = 0;
        mTopCard = null;
    }

    public Orientation getOrientation()
    {
        return mOrientation;
    }

    public void setOrientation(Orientation orientation)
    {
        if (orientation == null)
            throw new NullPointerException("Orientation may not be null");
        if (mOrientation != orientation) {
            this.mOrientation = orientation;
            if (orientation == Orientation.Disordered) {
                for (int i = 0; i < getChildCount(); i++) {
                    View child = getChildAt(i);
                    child.setRotation(getDisorderedRotation());
                }
            }
            else {
                for (int i = 0; i < getChildCount(); i++) {
                    View child = getChildAt(i);
                    child.setRotation(0);
                }
            }
            requestLayout();
        }

    }

    private float getDisorderedRotation()
    {
        return (float) Math.toDegrees(mRandom.nextGaussian() * DISORDERED_MAX_ROTATION_RADIANS);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        int requestedWidth = getMeasuredWidth() - getPaddingLeft() - getPaddingRight();
        int requestedHeight = getMeasuredHeight() - getPaddingTop() - getPaddingBottom();
        int childWidth, childHeight;

        if (mOrientation == Orientation.Disordered) {
            int R1, R2;
            if (requestedWidth >= requestedHeight) {
                R1 = requestedHeight;
                R2 = requestedWidth;
            }
            else {
                R1 = requestedWidth;
                R2 = requestedHeight;
            }
            childWidth = (int) ((R1 * Math.cos(DISORDERED_MAX_ROTATION_RADIANS) - R2 * Math.sin(DISORDERED_MAX_ROTATION_RADIANS)) / Math.cos(2 * DISORDERED_MAX_ROTATION_RADIANS));
            childHeight = (int) ((R2 * Math.cos(DISORDERED_MAX_ROTATION_RADIANS) - R1 * Math.sin(DISORDERED_MAX_ROTATION_RADIANS)) / Math.cos(2 * DISORDERED_MAX_ROTATION_RADIANS));
        }
        else {
            childWidth = requestedWidth;
            childHeight = requestedHeight;
        }

        int childWidthMeasureSpec, childHeightMeasureSpec;
        childWidthMeasureSpec = MeasureSpec.makeMeasureSpec(childWidth, MeasureSpec.AT_MOST);
        childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(childHeight, MeasureSpec.AT_MOST);

        for (int i = 0; i < getChildCount(); i++) {
            View child = getChildAt(i);
            assert child != null;
            child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
        }
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b)
    {
        super.onLayout(changed, l, t, r, b);

        for (int i = 0; i < getChildCount(); i++) {
            boundsRect.set(0, 0, getWidth(), getHeight());

            View view = getChildAt(i);
            int w, h;
            w = view.getMeasuredWidth();
            h = view.getMeasuredHeight();

            Gravity.apply(mGravity, w, h, boundsRect, childRect);
            view.layout(childRect.left, childRect.top, childRect.right, childRect.bottom);
        }
    }

    private VelocityTracker mVelocityTracker = null;

    @Override
    public boolean onTouchEvent(MotionEvent event)
    {

        if (mTopCard == null) {
            return false;
        }
        if (mGestureDetector.onTouchEvent(event)) {
            return true;
        }
        Log.d("Touch Event", MotionEvent.actionToString(event.getActionMasked()) + " ");
        final int pointerIndex;
        final float x, y;
        final float dx, dy;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:

                if (mVelocityTracker == null) {
                    mVelocityTracker = VelocityTracker.obtain();
                }
                else {
                    mVelocityTracker.clear();
                }
                mVelocityTracker.addMovement(event);


                mTopCard.getHitRect(childRect);

                pointerIndex = event.getActionIndex();
                x = event.getX(pointerIndex);
                y = event.getY(pointerIndex);

                if (!childRect.contains((int) x, (int) y)) {
                    return false;
                }
                mLastTouchX = x;
                mLastTouchY = y;
                mActivePointerId = event.getPointerId(pointerIndex);


                float[] points = new float[]{x - mTopCard.getLeft(), y - mTopCard.getTop()};
                mTopCard.getMatrix().invert(mMatrix);
                mMatrix.mapPoints(points);
                mTopCard.setPivotX(points[0]);
                mTopCard.setPivotY(points[1]);

                break;
            case MotionEvent.ACTION_MOVE:

                mVelocityTracker.addMovement(event);
                mVelocityTracker.computeCurrentVelocity(1000);
                pointerIndex = event.findPointerIndex(mActivePointerId);
                x = event.getX(pointerIndex);
                y = event.getY(pointerIndex);

                dx = x - mLastTouchX;
                dy = y - mLastTouchY;

                if (Math.abs(dx) > mTouchSlop || Math.abs(dy) > mTouchSlop) {
                    mDragging = true;
                }

                if (!mDragging) {
                    return true;
                }

                mTopCard.setTranslationX(mTopCard.getTranslationX() + dx);
                mTopCard.setTranslationY(mTopCard.getTranslationY() + dy);

                mTopCard.setRotation(5 * mTopCard.getTranslationX() / (getWidth() / 2.f)); //used to be **40** * mtopcard.gettranslationx

                mLastTouchX = x;
                mLastTouchY = y;


                float targetX = mTopCard.getX();
                float targetY = mTopCard.getY();
                long duration = 0;

                boundsRect.set(0 - mTopCard.getWidth() - 100, 0 - mTopCard.getHeight() - 100, getWidth() + 100, getHeight() + 100);

                float velocityX;
                float velocityY;

                final int pointerid = event.getPointerId(pointerIndex);

                velocityX = mVelocityTracker.getXVelocity(pointerid);
                velocityY = mVelocityTracker.getYVelocity(pointerid);

//                while (boundsRect.contains((int) targetX, (int) targetY)) {
//                    targetX += velocityX / 10;
//                    targetY += velocityY / 10;
//                }
//
//                OverlayView overlayView = null;
//
//                if (targetX > 0 && (targetY < 1500 && targetY > -1500)) {
//                    overlayView = (OverlayView) mTopCard.findViewById(R.id.like_overlay);
//                    overlayView.show();
//                    overlayView.setAlpha(128);
//                }
//                else if(targetX < 0 && (targetY < 1500 && targetY > -1500)){
//                    overlayView = (OverlayView) mTopCard.findViewById(R.id.dislike_overlay);
//                    overlayView.show();
//                    overlayView.setAlpha(128);
//                }
//                else if(targetY < 0 && (targetX < 1000 && targetX > -1000)){
//                    overlayView = (OverlayView) mTopCard.findViewById(R.id.holding_overlay);
//                    overlayView.show();
//                    overlayView.setAlpha(128);
//                } else if(targetY > 0 && (targetX < 700 && targetX > -700)){
//                    overlayView = (OverlayView) mTopCard.findViewById(R.id.comment_overlay);
//                    overlayView.show();
//                    overlayView.setAlpha(128);
//                }


                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (!mDragging) {
                    return true;
                }
                mDragging = false;
                mActivePointerId = INVALID_POINTER_ID;
                ValueAnimator animator = ObjectAnimator.ofPropertyValuesHolder(mTopCard,
                        PropertyValuesHolder.ofFloat("translationX", 0),
                        PropertyValuesHolder.ofFloat("translationY", 0),
                        PropertyValuesHolder.ofFloat("rotation", 0), //0 was originally (float) Math.toDegrees(mRandom.nextGaussian() * DISORDERED_MAX_ROTATION_RADIANS)
                        PropertyValuesHolder.ofFloat("pivotX", mTopCard.getWidth() / 2.f),
                        PropertyValuesHolder.ofFloat("pivotY", mTopCard.getHeight() / 2.f)
                ).setDuration(250);
                animator.setInterpolator(new AccelerateInterpolator());
                animator.start();
                break;
            case MotionEvent.ACTION_POINTER_UP:
                pointerIndex = event.getActionIndex();
                final int pointerId = event.getPointerId(pointerIndex);

                if (pointerId == mActivePointerId) {
                    final int newPointerIndex = pointerIndex == 0 ? 1 : 0;
                    mLastTouchX = event.getX(newPointerIndex);
                    mLastTouchY = event.getY(newPointerIndex);

                    mActivePointerId = event.getPointerId(newPointerIndex);
                }
                break;
        }

        return true;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event)
    {
        if (mTopCard == null) {
            return false;
        }
        if (mGestureDetector.onTouchEvent(event)) {
            return true;
        }
        final int pointerIndex;
        final float x, y;
        final float dx, dy;
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
//                mTopCard.getHitRect(childRect);

                CardModel cardModel = (CardModel) getAdapter().getItem(getChildCount() - 1);

//                pointerIndex = event.getActionIndex();
//                x = event.getX(pointerIndex);
//                y = event.getY(pointerIndex);
//
//                if (!childRect.contains((int) x, (int) y)) {
//                    return false;
//                }
//
//                mLastTouchX = x;
//                mLastTouchY = y;
//                mActivePointerId = event.getPointerId(pointerIndex);
                break;
            case MotionEvent.ACTION_MOVE:
                pointerIndex = event.findPointerIndex(mActivePointerId);
                x = event.getX(pointerIndex);
                y = event.getY(pointerIndex);
                if (Math.abs(x - mLastTouchX) > mTouchSlop || Math.abs(y - mLastTouchY) > mTouchSlop) {
                    float[] points = new float[]{x - mTopCard.getLeft(), y - mTopCard.getTop()};
                    mTopCard.getMatrix().invert(mMatrix);
                    mMatrix.mapPoints(points);
                    mTopCard.setPivotX(points[0]);
                    mTopCard.setPivotY(points[1]);
                    return true;
                }
        }

        return false;
    }

    @Override
    public View getSelectedView()
    {
        return mTopCard;
        //throw new UnsupportedOperationException();
    }

    @Override
    public void setSelection(int position)
    {
        throw new UnsupportedOperationException();
    }

    public int getGravity()
    {
        return mGravity;
    }

    public void setGravity(int gravity)
    {
        mGravity = gravity;
    }

    @Override
    public boolean onDrag(View view, DragEvent dragEvent)
    {

        return false;
    }

    public static class LayoutParams extends ViewGroup.LayoutParams
    {

        int viewType;

        public LayoutParams(Context c, AttributeSet attrs)
        {
            super(c, attrs);
        }

        public LayoutParams(int width, int height)
        {
            super(width, height);
        }

        public LayoutParams(ViewGroup.LayoutParams source)
        {
            super(source);
        }

        public LayoutParams(int w, int h, int viewType)
        {
            super(w, h);
            this.viewType = viewType;
        }
    }

    private class GestureListener extends SimpleOnGestureListener
    {
        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY)
        {
            final View topCard = mTopCard;
            float dx = e2.getX() - e1.getX();
            float dy = e2.getY() - e1.getY();
            Log.v("x and y are", mTopCard.getX() + ", " + mTopCard.getY());
            if ((Math.abs(dx) > mTouchSlop * 4 || Math.abs(dy) > mTouchSlop * 4)  //TODO: Maybe change the value mTouchSlop so that it doesnt fling as easily
                    && (Math.abs(mTopCard.getX()) > 350 || Math.abs(mTopCard.getY()) > 250)
                    && (Math.abs(velocityX) > mFlingSlop * 3 || Math.abs(velocityY) > mFlingSlop * 3)) {
                float targetX = topCard.getX();
                float targetY = topCard.getY();
                long duration = 0;

                boundsRect.set(0 - topCard.getWidth() - 100, 0 - topCard.getHeight() - 100, getWidth() + 100, getHeight() + 100);


                while (boundsRect.contains((int) targetX, (int) targetY)) {
                    targetX += velocityX / 10;
                    targetY += velocityY / 10;
                    duration += 100;
                }

                duration = Math.min(150, duration);

                mTopCard = getChildAt(getChildCount() - 2);
                CardModel cardModel = (CardModel) getAdapter().getItem(/*getChildCount() - 1*/mNextAdapterPosition - 3);

                if (mTopCard != null)
                    mTopCard.setLayerType(LAYER_TYPE_HARDWARE, null);

                if (cardModel.getOnCardDismissedListener() != null) {
                    if (targetX > 0 && (targetY < 1500 && targetY > -1500)) {
                        cardModel.getOnCardDismissedListener().onLike(cardModel);
                    }
                    else if (targetX < 0 && (targetY < 1500 && targetY > -1500)) {
                        cardModel.getOnCardDismissedListener().onDislike(cardModel);
                    }
                    else if (targetY < 0 && (targetX < 1000 && targetX > -1000)) {
                        cardModel.getOnCardDismissedListener().onUp(cardModel);
                    }
                    else if (targetY > 0 && (targetX < 700 && targetX > -700)) {
                        cardModel.getOnCardDismissedListener().onDown(cardModel);
                    }
                    else {
                        topCard.animate()
                                .setDuration(duration)
                                .setInterpolator(new DecelerateInterpolator())
                                .translationX(0)
                                .translationY(0)
                                .rotation(0);
                        return true;
                    }
                }

                topCard.animate()
                        .setDuration(duration)
                        .setInterpolator(new AccelerateInterpolator())
                        .x(targetX)
                        .y(targetY)
                        .rotation(Math.copySign(25, velocityX)) //used to be 45, not 35
                        .setListener(new AnimatorListenerAdapter()
                        {
                            @Override
                            public void onAnimationEnd(Animator animation)
                            {
                                removeViewInLayout(topCard);
                                ensureFull();
                            }

                            @Override
                            public void onAnimationCancel(Animator animation)
                            {
                                onAnimationEnd(animation);
                            }
                        });


                return true;
            }
            else
                return false;
        }

        @Override
        public boolean onSingleTapConfirmed(MotionEvent e)
        {
            CardModel cardModel = (CardModel) getAdapter().getItem(mNextAdapterPosition - 3);
            cardModel.getOnClickListener().OnClickListener(cardModel);
            return true;
        }
    }

    public void like() //used to animate swiping a view off TODO: call this method when you click like on item detail page
    {
        final View topCard = mTopCard;

        mTopCard = getChildAt(getChildCount() - 2);
        CardModel cardModel = (CardModel) getAdapter().getItem(0);

        if (mTopCard != null)
            mTopCard.setLayerType(LAYER_TYPE_HARDWARE, null);

        topCard.animate()
                .setDuration(500)
                .alpha(.75f)
                .setInterpolator(new LinearInterpolator())
                .x(topCard.getWidth())
                .y(topCard.getY())
                .rotation(45)
                .setListener(new AnimatorListenerAdapter()
                {
                    @Override
                    public void onAnimationEnd(Animator animation)
                    {
                        removeViewInLayout(topCard);
                        ensureFull();
                    }

                    @Override
                    public void onAnimationCancel(Animator animation)
                    {
                        onAnimationEnd(animation);
                    }
                });

        if (cardModel.getOnCardDismissedListener() != null) {
            cardModel.getOnCardDismissedListener().onLike(cardModel);
        }
    }

}
