package com.bakkle.bakkle.AddItem.MaterialCamera;

import android.app.Fragment;
import android.support.annotation.NonNull;

import com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity;
import com.bakkle.bakkle.AddItem.MaterialCamera.internal.CameraFragment;

public class CaptureActivity extends BaseCaptureActivity
{

    @Override
    @NonNull
    public Fragment getFragment() {
        return CameraFragment.newInstance();
    }
}