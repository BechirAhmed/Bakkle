package com.bakkle.bakkle.Helpers;

/**
 * Created by vanshgandhi on 7/7/15.
 */
import android.content.Context;
import android.graphics.Bitmap;

// Code borrowed from Nicolas Pomepuy
// https://github.com/PomepuyN/BlurEffectForAndroidDesign
public class BlurDarken {

    public static Bitmap apply(Context context, Bitmap sentBitmap) {
        return apply(context, sentBitmap, 23);
    }

    public static Bitmap apply(Context context, Bitmap sentBitmap, int radius) {
        return sentBitmap;

//        Bitmap bitmap = sentBitmap.copy(sentBitmap.getConfig(), true);
//
//        final RenderScript rs = RenderScript.create(context);
//        final Allocation input = Allocation.createFromBitmap(rs, sentBitmap, Allocation.MipmapControl.MIPMAP_NONE,
//                Allocation.USAGE_SCRIPT);
//        final Allocation output = Allocation.createTyped(rs, input.getType());
//        final ScriptIntrinsicBlur script = ScriptIntrinsicBlur.create(rs, Element.U8_4(rs));
//        script.setRadius(radius);
//        script.setInput(input);
//        script.forEach(output);
//        output.copyTo(bitmap);
        //return bitmap;
    }
}