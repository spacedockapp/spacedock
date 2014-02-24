package com.funnyhatsoftware.spacedock;

import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.DashPathEffect;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;

public class ArcDrawable extends Drawable {
    private int mFrontArc;
    private int mRearArc;
    private final Paint mFillPaint = new Paint();
    private final Paint mStrokePaint = new Paint();
    private final Paint mRearPaint;
    private final RectF mRectF = new RectF();
    private final int mLineWidth;

    public ArcDrawable(Resources res) {
        mLineWidth = res.getDimensionPixelSize(R.dimen.maneuver_line_size);
        mFillPaint.setAntiAlias(true);
        mFillPaint.setStyle(Paint.Style.FILL);
        mStrokePaint.setAntiAlias(true);
        mStrokePaint.setStyle(Paint.Style.STROKE);
        mStrokePaint.setStrokeWidth(mLineWidth);

        mRearPaint = new Paint(mStrokePaint);
        mRearPaint.setPathEffect(new DashPathEffect(new float[]{mLineWidth, 2 * mLineWidth}, 0));
        mRearPaint.setStrokeCap(Paint.Cap.ROUND);
    }

    public void setArc(int color, int frontArc, int rearArc) {
        mFrontArc = frontArc;
        mRearArc = rearArc;
        mFillPaint.setColor(color);
        mFillPaint.setAlpha(0x80);
        mStrokePaint.setColor(color);
        mStrokePaint.setAlpha(0xff);
        mRearPaint.setColor(color);
        mRearPaint.setAlpha(0xff);
        invalidateSelf(); // TODO: remove
    }

    private void drawArc(Canvas canvas, int arcSize, int offset, Paint fill, Paint stroke) {
        if (arcSize == 0) return;

        if (fill != null) {
            canvas.drawArc(mRectF, offset - arcSize / 2f, arcSize, true, fill);
        }
        if (stroke != null) {
            canvas.drawArc(mRectF, offset - arcSize / 2f, arcSize, true, stroke);
        }
    }

    @Override
    public void draw(Canvas canvas) {
        mRectF.set(getBounds());
        mRectF.inset(mLineWidth, mLineWidth);
        drawArc(canvas, mFrontArc, -90, mFillPaint, mStrokePaint);
        drawArc(canvas, mRearArc, 90, null, mRearPaint);
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
