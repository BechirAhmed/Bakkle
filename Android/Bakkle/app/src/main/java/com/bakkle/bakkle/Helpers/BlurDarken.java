package com.bakkle.bakkle.Helpers;

/**
 * Created by vanshgandhi on 7/7/15.
 */

import android.content.Context;
import android.graphics.Bitmap;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicBlur;
//import android.support.v8.renderscript.Allocation;
//import android.support.v8.renderscript.Element;
//import android.support.v8.renderscript.RenderScript;
//import android.support.v8.renderscript.ScriptIntrinsicBlur;

// Code borrowed from Nicolas Pomepuy
// https://github.com/PomepuyN/BlurEffectForAndroidDesign
public class BlurDarken {

    public static Bitmap apply(Context context, Bitmap sentBitmap) {
        return apply(context, sentBitmap, 23);
    }

    public static Bitmap apply(Context context, Bitmap sentBitmap, int radius) {
        Bitmap bitmap = sentBitmap.copy(sentBitmap.getConfig(), true);

        final RenderScript rs = RenderScript.create(context);
        final Allocation input = Allocation.createFromBitmap(rs, sentBitmap, Allocation.MipmapControl.MIPMAP_NONE,
                Allocation.USAGE_SCRIPT);
        final Allocation output = Allocation.createTyped(rs, input.getType());
        final ScriptIntrinsicBlur script = ScriptIntrinsicBlur.create(rs, Element.U8_4(rs));
        script.setRadius(radius);
        script.setInput(input);
        script.forEach(output);
        output.copyTo(bitmap);
        return bitmap;
    }
}