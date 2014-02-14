package com.funnyhatsoftware.spacedock;

import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;

public class ArcDrawable extends Drawable {
    private int mFrontArc;
    private int mRearArc;
    private final Paint mFillPaint = new Paint();
    private final Paint mStrokePaint = new Paint();
    private final RectF mRectF = new RectF();

    public ArcDrawable() {
        mFillPaint.setAntiAlias(true);
        mFillPaint.setStyle(Paint.Style.FILL);
        mStrokePaint.setAntiAlias(true);
        mStrokePaint.setStyle(Paint.Style.STROKE);
    }

    public void setArc(int color, int frontArc, int rearArc) {
        mFrontArc = frontArc;
        mRearArc = rearArc;
        mFillPaint.setColor(color);
        mFillPaint.setAlpha(0x50);
        mStrokePaint.setColor(color);
        mStrokePaint.setAlpha(0xff);
        invalidateSelf(); // TODO: remove
    }

    private void drawArc(Canvas canvas, int arcSize, int offset) {
        if (arcSize == 0) return;

        canvas.drawArc(mRectF, offset - arcSize / 2f, arcSize, true, mFillPaint);
        canvas.drawArc(mRectF, offset - arcSize / 2f, arcSize, true, mStrokePaint);
    }

    @Override
    public void draw(Canvas canvas) {
        mRectF.set(getBounds());
        drawArc(canvas, mFrontArc, -90);
        drawArc(canvas, mRearArc, 90);
    }

    @Override
    public void setAlpha(int alpha) {

    }

    @Override
    public void setColorFilter(ColorFilter cf) {

    }

    @Override
    public int getOpacity() {
        return 0;
    }
}
