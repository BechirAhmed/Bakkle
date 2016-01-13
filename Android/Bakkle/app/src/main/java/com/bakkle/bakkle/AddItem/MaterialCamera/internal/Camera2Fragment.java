package com.bakkle.bakkle.AddItem.MaterialCamera.internal;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.RectF;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.util.Size;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.widget.Toast;

import com.afollestad.materialdialogs.DialogAction;
import com.afollestad.materialdialogs.MaterialDialog;
import com.bakkle.bakkle.AddItem.MaterialCamera.util.Degrees;
import com.bakkle.bakkle.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

/**
 * @author Aidan Follestad (afollestad)
 */
@TargetApi (Build.VERSION_CODES.LOLLIPOP)
public class Camera2Fragment extends BaseCameraFragment implements View.OnClickListener
{
    private static final int    REQUEST_CAMERA_PERMISSION = 1;
    private static final String FRAGMENT_DIALOG           = "dialog";

    /**
     * Camera state: Showing camera preview.
     */
    private static final int STATE_PREVIEW = 0;

    /**
     * Camera state: Waiting for the focus to be locked.
     */
    private static final int STATE_WAITING_LOCK = 1;

    /**
     * Camera state: Waiting for the exposure to be precapture state.
     */
    private static final int STATE_WAITING_PRECAPTURE = 2;

    /**
     * Camera state: Waiting for the exposure state to be something other than precapture.
     */
    private static final int STATE_WAITING_NON_PRECAPTURE = 3;

    /**
     * Camera state: Picture was taken.
     */
    private static final int STATE_PICTURE_TAKEN = 4;

    /**
     * Max preview width that is guaranteed by Camera2 API
     */
    private static final int MAX_PREVIEW_WIDTH = 1920;

    /**
     * Max preview height that is guaranteed by Camera2 API
     */
    private static final int MAX_PREVIEW_HEIGHT = 1080;

    /**
     * The current state of camera state for taking pictures.
     *
     * @see #mCaptureCallback
     */
    private int mState = STATE_PREVIEW;

    private CameraDevice         mCameraDevice;
    private CameraCaptureSession mPreviewSession;
    private AutoFitTextureView   mTextureView;

    private CameraCaptureSession   mCaptureSession;
    private Size                   mPreviewSize;
    private Size                   mVideoSize;
    @Degrees.DegreeUnits
    private int                    mDisplayOrientation;
    private CaptureRequest.Builder mPreviewBuilder;
    private HandlerThread          mBackgroundThread;
    private Handler                mBackgroundHandler;
    private final Semaphore mCameraOpenCloseLock = new Semaphore(1);

    /**
     * An {@link ImageReader} that handles still image capture.
     */
    private ImageReader mImageReader;

    private final TextureView.SurfaceTextureListener mSurfaceTextureListener = new TextureView.SurfaceTextureListener()
    {
        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int width, int height)
        {
            openCamera();
        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int width,
                                                int height)
        {
            configureTransform(width, height);
        }

        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture)
        {
            return true;
        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture surfaceTexture)
        {
        }
    };

    private final CameraDevice.StateCallback mStateCallback = new CameraDevice.StateCallback()
    {
        @Override
        public void onOpened(@NonNull CameraDevice cameraDevice)
        {
            mCameraDevice = cameraDevice;
            startPreview(); //TODO: This will initiate a MediaRecorder!!!!
            mCameraOpenCloseLock.release();
            if (null != mTextureView) {
                configureTransform(mTextureView.getWidth(), mTextureView.getHeight());
            }
        }

        @Override
        public void onDisconnected(@NonNull CameraDevice cameraDevice)
        {
            mCameraOpenCloseLock.release();
            cameraDevice.close();
            mCameraDevice = null;
        }

        @Override
        public void onError(@NonNull CameraDevice cameraDevice, int error)
        {
            mCameraOpenCloseLock.release();
            cameraDevice.close();
            mCameraDevice = null;

            String errorMsg = "Unknown camera error";
            switch (error) {
                case CameraDevice.StateCallback.ERROR_CAMERA_IN_USE:
                    errorMsg = "Camera is already in use.";
                    break;
                case CameraDevice.StateCallback.ERROR_MAX_CAMERAS_IN_USE:
                    errorMsg = "Max number of cameras are open, close previous cameras first.";
                    break;
                case CameraDevice.StateCallback.ERROR_CAMERA_DISABLED:
                    errorMsg = "Camera is disabled, e.g. due to device policies.";
                    break;
                case CameraDevice.StateCallback.ERROR_CAMERA_DEVICE:
                    errorMsg = "Camera device has encountered a fatal error, please try again.";
                    break;
                case CameraDevice.StateCallback.ERROR_CAMERA_SERVICE:
                    errorMsg = "Camera service has encountered a fatal error, please try again.";
                    break;
            }
            throwError(new Exception(errorMsg));
        }
    };

    public static Camera2Fragment newInstance()
    {
        Camera2Fragment fragment = new Camera2Fragment();
        fragment.setRetainInstance(true);
        return fragment;
    }

    /**
     * In this sample, we choose a video size with 3x4 aspect ratio. Also, we don't use sizes larger
     * than 1080p, since MediaRecorder cannot handle such a high-resolution video.
     *
     * @param choices The list of available sizes
     * @return The video size
     */
    private static Size chooseVideoSize(Size[] choices)
    {
        Size backupSize = null;
        for (Size size : choices) {
            if (size.getHeight() <= PREFERRED_PIXEL_HEIGHT) {
                if (size.getWidth() == size.getHeight() * PREFERRED_ASPECT_RATIO) {
                    return size;
                }
                backupSize = size;
            }
        }
        if (backupSize != null) {
            return backupSize;
        }
        LOG(Camera2Fragment.class, "Couldn't find any suitable video size");
        return choices[choices.length - 1];
    }

    private static Size chooseOptimalSize(Size[] choices, int width, int height, Size aspectRatio)
    {
        // Collect the supported resolutions that are at least as big as the preview Surface
        List<Size> bigEnough = new ArrayList<>();
        int w = aspectRatio.getWidth();
        int h = aspectRatio.getHeight();
        for (Size option : choices) {
            if (option.getHeight() == option.getWidth() * h / w &&
                    option.getWidth() >= width && option.getHeight() >= height) {
                bigEnough.add(option);
            }
        }

        // Pick the smallest of those, assuming we found any
        if (bigEnough.size() > 0) {
            return Collections.min(bigEnough, new CompareSizesByArea());
        } else {
            LOG(Camera2Fragment.class, "Couldn't find any suitable preview size");
            return choices[0];
        }
    }

    @Override
    public void onViewCreated(final View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);
        mTextureView = (AutoFitTextureView) view.findViewById(R.id.texture);
    }

    @Override
    public void onDestroyView()
    {
        super.onDestroyView();
        mTextureView = null;
    }

    @Override
    public void onResume()
    {
        super.onResume();
        startBackgroundThread();
        if (mTextureView.isAvailable()) {
            openCamera();
        } else {
            mTextureView.setSurfaceTextureListener(mSurfaceTextureListener);
        }
    }

    @Override
    public void onPause()
    {
        stopBackgroundThread();
        super.onPause();
    }

    /**
     * Starts a background thread and its {@link Handler}.
     */
    private void startBackgroundThread()
    {
        mBackgroundThread = new HandlerThread("CameraBackground");
        mBackgroundThread.start();
        mBackgroundHandler = new Handler(mBackgroundThread.getLooper());
    }

    private void stopBackgroundThread()
    {
        stopCounter();
        mBackgroundThread.quitSafely();
        try {
            mBackgroundThread.join();
            mBackgroundThread = null;
            mBackgroundHandler = null;
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void openCamera()
    {
        if (ContextCompat.checkSelfPermission(getActivity(),
                Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            requestCameraPermission();
            return;
        }
        final int width = mTextureView.getWidth();
        final int height = mTextureView.getHeight();
        final Activity activity = getActivity();
        if (null == activity || activity.isFinishing()) {
            return;
        }
        CameraManager manager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
        try {
            if (!mCameraOpenCloseLock.tryAcquire(2500, TimeUnit.MILLISECONDS)) {
                throwError(new Exception("Time out waiting to lock camera opening."));
                return;
            }
            if (mInterface.getFrontCamera() == null || mInterface.getBackCamera() == null) {
                for (String cameraId : manager.getCameraIdList()) {
                    if (cameraId == null) {
                        continue;
                    }
                    if (mInterface.getFrontCamera() != null && mInterface.getBackCamera() != null) {
                        break;
                    }
                    CameraCharacteristics characteristics = manager.getCameraCharacteristics(
                            cameraId);
                    //noinspection ConstantConditions
                    int facing = characteristics.get(CameraCharacteristics.LENS_FACING);
                    if (facing == CameraCharacteristics.LENS_FACING_FRONT) {
                        mInterface.setFrontCamera(cameraId);
                    } else if (facing == CameraCharacteristics.LENS_FACING_BACK) {
                        mInterface.setBackCamera(cameraId);
                    }
                    StreamConfigurationMap map = characteristics.get(
                            CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                    if (map == null) {
                        continue;
                    }
                    // For still image captures, we use the largest available size.
                    Size largest = Collections.max(
                            Arrays.asList(map.getOutputSizes(ImageFormat.JPEG)),
                            new CompareSizesByArea());
                    mImageReader = ImageReader.newInstance(largest.getWidth(), largest.getHeight(),
                            ImageFormat.JPEG, /*maxImages*/2);
                    mImageReader.setOnImageAvailableListener(mOnImageAvailableListener,
                            mBackgroundHandler);
                }
            }
            if (mInterface.getCurrentCameraPosition() == com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_UNKNOWN) {
                if (getArguments().getBoolean(
                        com.bakkle.bakkle.AddItem.MaterialCamera.internal.CameraIntentKey.DEFAULT_TO_FRONT_FACING,
                        false)) {
                    // Check front facing first
                    if (mInterface.getFrontCamera() != null) {
                        mButtonFacing.setImageResource(R.drawable.mcam_camera_rear);
                        mInterface.setCameraPosition(
                                com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_FRONT);
                    } else {
                        mButtonFacing.setImageResource(R.drawable.mcam_camera_front);
                        if (mInterface.getBackCamera() != null) {
                            mInterface.setCameraPosition(
                                    com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_BACK);
                        } else {
                            mInterface.setCameraPosition(
                                    com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_UNKNOWN);
                        }
                    }
                } else {
                    // Check back facing first
                    if (mInterface.getBackCamera() != null) {
                        mButtonFacing.setImageResource(R.drawable.mcam_camera_front);
                        mInterface.setCameraPosition(
                                com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_BACK);
                    } else {
                        mButtonFacing.setImageResource(R.drawable.mcam_camera_rear);
                        if (mInterface.getFrontCamera() != null) {
                            mInterface.setCameraPosition(
                                    com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_FRONT);
                        } else {
                            mInterface.setCameraPosition(
                                    com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_UNKNOWN);
                        }
                    }
                }
            }

            // Choose the sizes for camera preview and video recording
            CameraCharacteristics characteristics = manager.getCameraCharacteristics(
                    (String) mInterface.getCurrentCameraId());
            StreamConfigurationMap map = characteristics.get(
                    CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
            assert map != null;
            mVideoSize = chooseVideoSize(map.getOutputSizes(MediaRecorder.class));
            mPreviewSize = chooseOptimalSize(map.getOutputSizes(SurfaceTexture.class), width,
                    height, mVideoSize);

            //noinspection ConstantConditions,ResourceType
            @Degrees.DegreeUnits final int sensorOrientation = characteristics.get(
                    CameraCharacteristics.SENSOR_ORIENTATION);

            @Degrees.DegreeUnits int deviceRotation = Degrees.getDisplayRotation(getActivity());
            mDisplayOrientation = Degrees.getDisplayOrientation(sensorOrientation, deviceRotation,
                    getCurrentCameraPosition() == com.bakkle.bakkle.AddItem.MaterialCamera.internal.BaseCaptureActivity.CAMERA_POSITION_FRONT);
            Log.d("Camera2Fragment",
                    String.format("Orientations: Sensor = %d˚, Device = %d˚, Display = %d˚",
                            sensorOrientation, deviceRotation, mDisplayOrientation));

            int orientation = com.bakkle.bakkle.AddItem.MaterialCamera.internal.VideoStreamView.getScreenOrientation(
                    activity);
            if (orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE || orientation == ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE) {
                mTextureView.setAspectRatio(mPreviewSize.getWidth(), mPreviewSize.getHeight());
            } else {
                mTextureView.setAspectRatio(mPreviewSize.getHeight(), mPreviewSize.getWidth());
            }
            configureTransform(width, height);
            mMediaRecorder = new MediaRecorder();
            // noinspection ResourceType
            manager.openCamera((String) mInterface.getCurrentCameraId(), mStateCallback, null);
        } catch (CameraAccessException e) {
            throwError(new Exception("Cannot access the camera.", e));
        } catch (NullPointerException e) {
            // Currently an NPE is thrown when the Camera2API is used but not supported on the
            // device this code runs.
            new ErrorDialog().show(getFragmentManager(), "dialog");
        } catch (InterruptedException e) {
            throwError(new Exception("Interrupted while trying to lock camera opening.", e));
        }
    }

    @Override
    public void closeCamera()
    {
        try {
            mCameraOpenCloseLock.acquire();
            if (null != mCaptureSession) {
                mCaptureSession.close();
                mCaptureSession = null;
            }
            if (null != mCameraDevice) {
                mCameraDevice.close();
                mCameraDevice = null;
            }
            if (null != mMediaRecorder) {
                mMediaRecorder.release();
                mMediaRecorder = null;
            }
        } catch (InterruptedException e) {
            throwError(new Exception("Interrupted while trying to lock camera closing.", e));
        } finally {
            mCameraOpenCloseLock.release();
        }
    }

    private void startPreview()
    {
        if (null == mCameraDevice || !mTextureView.isAvailable() || null == mPreviewSize) {
            return;
        }
        try {
            if (!setUpMediaRecorder()) {
                return;
            }
            SurfaceTexture texture = mTextureView.getSurfaceTexture();
            assert texture != null;
            texture.setDefaultBufferSize(mPreviewSize.getWidth(), mPreviewSize.getHeight());
            mPreviewBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
            List<Surface> surfaces = new ArrayList<>();

            Surface previewSurface = new Surface(texture);
            surfaces.add(previewSurface);
            mPreviewBuilder.addTarget(previewSurface);

            Surface recorderSurface = mMediaRecorder.getSurface();
            surfaces.add(recorderSurface);
            mPreviewBuilder.addTarget(recorderSurface);

            mCameraDevice.createCaptureSession(surfaces, new CameraCaptureSession.StateCallback()
            {
                @Override
                public void onConfigured(@NonNull CameraCaptureSession cameraCaptureSession)
                {
                    mPreviewSession = cameraCaptureSession;
                    updatePreview();
                    mCaptureSession = cameraCaptureSession;

                    try {
                        // Auto focus should be continuous for camera preview.
                        mPreviewBuilder.set(CaptureRequest.CONTROL_AF_MODE,
                                CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);

                        mCaptureSession.setRepeatingRequest(mPreviewBuilder.build(),
                                mCaptureCallback, mBackgroundHandler);
                    } catch (CameraAccessException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession)
                {
                    throwError(new Exception("Camera configuration failed"));
                }
            }, mBackgroundHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private void updatePreview()
    {
        if (null == mCameraDevice) {
            return;
        }
        try {
            setUpCaptureRequestBuilder(mPreviewBuilder);
            HandlerThread thread = new HandlerThread("CameraPreview");
            thread.start();
            mPreviewSession.setRepeatingRequest(mPreviewBuilder.build(), null, mBackgroundHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private void setUpCaptureRequestBuilder(CaptureRequest.Builder builder)
    {
        builder.set(CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
    }

    private void configureTransform(int viewWidth, int viewHeight)
    {
        Activity activity = getActivity();
        if (null == mTextureView || null == mPreviewSize || null == activity) {
            return;
        }
        int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        Matrix matrix = new Matrix();
        RectF viewRect = new RectF(0, 0, viewWidth, viewHeight);
        RectF bufferRect = new RectF(0, 0, mPreviewSize.getHeight(), mPreviewSize.getWidth());
        float centerX = viewRect.centerX();
        float centerY = viewRect.centerY();
        if (Surface.ROTATION_90 == rotation || Surface.ROTATION_270 == rotation) {
            bufferRect.offset(centerX - bufferRect.centerX(), centerY - bufferRect.centerY());
            matrix.setRectToRect(viewRect, bufferRect, Matrix.ScaleToFit.FILL);
            float scale = Math.max((float) viewHeight / mPreviewSize.getHeight(),
                    (float) viewWidth / mPreviewSize.getWidth());
            matrix.postScale(scale, scale, centerX, centerY);
            matrix.postRotate(90 * (rotation - 2), centerX, centerY);
        } else if (Surface.ROTATION_180 == rotation) {
            matrix.postRotate(180, centerX, centerY);
        }
        mTextureView.setTransform(matrix);
    }

    private boolean setUpMediaRecorder()
    {
        final Activity activity = getActivity();
        if (null == activity) {
            return false;
        }
        if (mMediaRecorder == null) {
            mMediaRecorder = new MediaRecorder();
        }
        boolean canUseAudio = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            canUseAudio = activity.checkSelfPermission(
                    Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
        }
        if (canUseAudio) {
            mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.CAMCORDER);
        } else {
            Toast.makeText(getActivity(), R.string.mcam_no_audio_access, Toast.LENGTH_LONG).show();
        }
        mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
        mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
        mMediaRecorder.setVideoEncodingBitRate(5000000);
        mMediaRecorder.setVideoFrameRate(15);
        mMediaRecorder.setVideoSize(mVideoSize.getWidth(), mVideoSize.getHeight());
        mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
        if (canUseAudio) {
            mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
        }
        Uri uri = Uri.fromFile(getOutputVideoFile());
        mOutputUri = uri.toString();
        mMediaRecorder.setOutputFile(uri.getPath());
        mMediaRecorder.setOrientationHint(mDisplayOrientation);

        try {
            mMediaRecorder.prepare();
            return true;
        } catch (Throwable e) {
            throwError(new Exception("Failed to prepare the media recorder: " + e.getMessage(), e));
            return false;
        }
    }

    @Override
    public boolean startRecordingVideo()
    {
        super.startRecordingVideo();
        try {
            // UI
            mButtonVideo.setImageResource(R.drawable.mcam_action_stop);
            mButtonFacing.setVisibility(View.GONE);

            // Only start counter if count down wasn't already started
            if (!mInterface.hasLengthLimit()) {
                mInterface.setRecordingStart(System.currentTimeMillis());
                startCounter();
            }

            // Start recording
            mMediaRecorder.start();

            mButtonVideo.setEnabled(false);
            mButtonVideo.postDelayed(new Runnable()
            {
                @Override
                public void run()
                {
                    mButtonVideo.setEnabled(true);
                }
            }, 200);

            return true;
        } catch (Throwable t) {
            t.printStackTrace();
            mInterface.setRecordingStart(-1);
            stopRecordingVideo(false);
            throwError(new Exception("Failed to start recording: " + t.getMessage(), t));
        }
        return false;
    }

    @Override
    public void stopRecordingVideo(boolean reachedZero)
    {
        super.stopRecordingVideo(reachedZero);

        if (mInterface.hasLengthLimit() && mInterface.shouldAutoSubmit() &&
                (mInterface.getRecordingStart() < 0 || mMediaRecorder == null)) {
            stopCounter();
            releaseRecorder();
            mInterface.onShowPreview(mOutputUri, reachedZero);
            return;
        }

        if (!mInterface.didRecord()) {
            mOutputUri = null;
        }

        releaseRecorder();
        mButtonVideo.setImageResource(R.drawable.ic_videocam);
        mButtonFacing.setVisibility(View.VISIBLE);
        if (mInterface.getRecordingStart() > -1 && getActivity() != null) {
            mInterface.onShowPreview(mOutputUri, reachedZero);
        }

        stopCounter();
    }

    /**
     * Initiate a still image capture.
     */
    public void takePicture()
    {
        super.takePicture();
        lockFocus();
    }

    /**
     * Lock the focus as the first step for a still image capture.
     */
    private void lockFocus()
    {
        try {
            // This is how to tell the camera to lock focus.
            mPreviewBuilder.set(CaptureRequest.CONTROL_AF_TRIGGER,
                    CameraMetadata.CONTROL_AF_TRIGGER_START);
            // Tell #mCaptureCallback to wait for the lock.
            mState = STATE_WAITING_LOCK;
            mCaptureSession.capture(mPreviewBuilder.build(), mCaptureCallback, mBackgroundHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    /**
     * Run the precapture sequence for capturing a still image. This method should be called when
     * we get a response in {@link #mCaptureCallback} from {@link #lockFocus()}.
     */
    private void runPrecaptureSequence()
    {
        try {
            // This is how to tell the camera to trigger.
            mPreviewBuilder.set(CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
                    CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_START);
            // Tell #mCaptureCallback to wait for the precapture sequence to be set.
            mState = STATE_WAITING_PRECAPTURE;
            mCaptureSession.capture(mPreviewBuilder.build(), mCaptureCallback, mBackgroundHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    /**
     * Capture a still picture. This method should be called when we get a response in
     * {@link #mCaptureCallback} from both {@link #lockFocus()}.
     */
    private void captureStillPicture()
    {
        try {
            final Activity activity = getActivity();
            if (null == activity || null == mCameraDevice) {
                return;
            }
            // This is the CaptureRequest.Builder that we use to take a picture.
            final CaptureRequest.Builder captureBuilder = mCameraDevice.createCaptureRequest(
                    CameraDevice.TEMPLATE_STILL_CAPTURE);
            captureBuilder.addTarget(mImageReader.getSurface());

            // Use the same AE and AF modes as the preview.
            captureBuilder.set(CaptureRequest.CONTROL_AF_MODE,
                    CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);

            // Orientation
            int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
            captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, mDisplayOrientation);

            CameraCaptureSession.CaptureCallback CaptureCallback = new CameraCaptureSession.CaptureCallback()
            {

                @Override
                public void onCaptureCompleted(@NonNull CameraCaptureSession session,
                                               @NonNull CaptureRequest request,
                                               @NonNull TotalCaptureResult result)
                {
                    unlockFocus();
                    closeCamera();
                    releaseRecorder();
                    mInterface.useImage(mOutputUri);

                }
            };

            mPreviewSession.stopRepeating();
            mPreviewSession.capture(captureBuilder.build(), CaptureCallback, null);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    /**
     * Unlock the focus. This method should be called when still image capture sequence is
     * finished.
     */
    private void unlockFocus()
    {
        try {
            // Reset the auto-focus trigger
            mPreviewBuilder.set(CaptureRequest.CONTROL_AF_TRIGGER,
                    CameraMetadata.CONTROL_AF_TRIGGER_CANCEL);
            mPreviewSession.capture(mPreviewBuilder.build(), mCaptureCallback, mBackgroundHandler);
            // After this, the camera will go back to the normal state of preview.
            mState = STATE_PREVIEW;
            mPreviewSession.setRepeatingRequest(mPreviewBuilder.build(), mCaptureCallback,
                    mBackgroundHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private final ImageReader.OnImageAvailableListener mOnImageAvailableListener = new ImageReader.OnImageAvailableListener()
    {

        @Override
        public void onImageAvailable(ImageReader reader)
        {
            File file = getOutputImageFile();
            mOutputUri = Uri.fromFile(file).toString();
            mBackgroundHandler.post(new ImageSaver(reader.acquireNextImage(), file));
        }

    };

    private CameraCaptureSession.CaptureCallback mCaptureCallback = new CameraCaptureSession.CaptureCallback()
    {

        private void process(CaptureResult result)
        {
            switch (mState) {
                case STATE_PREVIEW: {
                    // We have nothing to do when the camera preview is working normally.
                    break;
                }
                case STATE_WAITING_LOCK: {
                    Integer afState = result.get(CaptureResult.CONTROL_AF_STATE);
                    if (afState == null) {
                        captureStillPicture();
                    } else if (CaptureResult.CONTROL_AF_STATE_FOCUSED_LOCKED == afState || CaptureResult.CONTROL_AF_STATE_NOT_FOCUSED_LOCKED == afState) {
                        // CONTROL_AE_STATE can be null on some devices
                        Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
                        if (aeState == null || aeState == CaptureResult.CONTROL_AE_STATE_CONVERGED) {
                            mState = STATE_PICTURE_TAKEN;
                            captureStillPicture();
                        } else {
                            runPrecaptureSequence();
                        }
                    }
                    break;
                }
                case STATE_WAITING_PRECAPTURE: {
                    // CONTROL_AE_STATE can be null on some devices
                    Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
                    if (aeState == null ||
                            aeState == CaptureResult.CONTROL_AE_STATE_PRECAPTURE ||
                            aeState == CaptureRequest.CONTROL_AE_STATE_FLASH_REQUIRED) {
                        mState = STATE_WAITING_NON_PRECAPTURE;
                    }
                    break;
                }
                case STATE_WAITING_NON_PRECAPTURE: {
                    // CONTROL_AE_STATE can be null on some devices
                    Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
                    if (aeState == null || aeState != CaptureResult.CONTROL_AE_STATE_PRECAPTURE) {
                        mState = STATE_PICTURE_TAKEN;
                        captureStillPicture();
                    }
                    break;
                }
            }
        }

        @Override
        public void onCaptureProgressed(@NonNull CameraCaptureSession session,
                                        @NonNull CaptureRequest request,
                                        @NonNull CaptureResult partialResult)
        {
            process(partialResult);
        }

        @Override
        public void onCaptureCompleted(@NonNull CameraCaptureSession session,
                                       @NonNull CaptureRequest request,
                                       @NonNull TotalCaptureResult result)
        {
            process(result);
        }

    };

    private void requestCameraPermission()
    {
        requestPermissions(new String[]{Manifest.permission.CAMERA}, REQUEST_CAMERA_PERMISSION);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults)
    {
        if (requestCode == REQUEST_CAMERA_PERMISSION) {
            if (grantResults.length != 1 || grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                ErrorDialog2.newInstance("Camera needs to be enabled")
                        .show(getChildFragmentManager(), FRAGMENT_DIALOG);
            }
        } else {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    static class CompareSizesByArea implements Comparator<Size>
    {
        @Override
        public int compare(Size lhs, Size rhs)
        {
            // We cast here to ensure the multiplications won't overflow
            return Long.signum(
                    (long) lhs.getWidth() * lhs.getHeight() - (long) rhs.getWidth() * rhs.getHeight());
        }
    }

    /**
     * Saves a JPEG {@link Image} into the specified {@link File}.
     */
    private static class ImageSaver implements Runnable
    {

        /**
         * The JPEG image
         */
        private final Image mImage;
        /**
         * The file we save the image into.
         */
        private final File  mFile;

        public ImageSaver(Image image, File file)
        {
            mImage = image;
            mFile = file;
        }

        @Override
        public void run()
        {
            ByteBuffer buffer = mImage.getPlanes()[0].getBuffer();
            byte[] bytes = new byte[buffer.remaining()];
            buffer.get(bytes);
            FileOutputStream output = null;
            try {
                output = new FileOutputStream(mFile);
                output.write(bytes);
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                mImage.close();
                if (null != output) {
                    try {
                        output.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }

    }

    public static class ErrorDialog extends DialogFragment
    {
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState)
        {
            final Activity activity = getActivity();
            return new MaterialDialog.Builder(activity).content(
                    "This device doesn't support the Camera2 API.")
                    .positiveText(android.R.string.ok)
                    .onAny(new MaterialDialog.SingleButtonCallback()
                    {
                        @Override
                        public void onClick(@NonNull MaterialDialog materialDialog,
                                            @NonNull DialogAction dialogAction)
                        {
                            activity.finish();
                        }
                    })
                    .build();
        }
    }

    /**
     * Shows an error message dialog.
     */
    public static class ErrorDialog2 extends DialogFragment
    { //TODO: Combine the 2 error dialog classes

        private static final String ARG_MESSAGE = "message";

        public static ErrorDialog newInstance(String message)
        {
            ErrorDialog dialog = new ErrorDialog();
            Bundle args = new Bundle();
            args.putString(ARG_MESSAGE, message);
            dialog.setArguments(args);
            return dialog;
        }

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState)
        {
            final Activity activity = getActivity();
            return new AlertDialog.Builder(activity).setMessage(
                    getArguments().getString(ARG_MESSAGE))
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i)
                        {
                            activity.finish();
                        }
                    })
                    .create();
        }

    }

}