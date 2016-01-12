package com.bakkle.bakkle.AddItem.MaterialCamera;

import android.app.Fragment;
import android.support.annotation.NonNull;

import com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity;
import com.bakkle.bakkle.AddItem.MaterialCamera.internal.Camera2Fragment;

public class CaptureActivity2 extends BaseCaptureActivity
{

    @Override
    @NonNull
    public Fragment getFragment() {
        return Camera2Fragment.newInstance();
    }
}