package com.wenchao.cardstack;

import android.util.Log;

public class DefaultStackEventListener implements CardStack.CardEventListener {

    private float mThreshold;

    public DefaultStackEventListener(int i) {
        mThreshold = i;
    }

    @Override
    public boolean swipeEnd(int section, float distance) {

        Log.v("test", "test swipeend");

        if(distance > mThreshold){
            return true;
        }else{
            return false;
        }
    }

    @Override
    public boolean swipeStart(int section, float distance) {

        return false;
    }

    @Override
    public boolean swipeContinue(int section, float distanceX, float distanceY) {
        return false;
    }

    @Override
    public void discarded(int mIndex,int direction) {

    }

    @Override
    public void topCardTapped() {

    }


}
