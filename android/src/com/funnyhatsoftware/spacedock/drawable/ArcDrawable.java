package com.funnyhatsoftware.spacedock.drawable;

import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.DashPathEffect;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;

import com.funnyhatsoftware.spacedock.R;

public class ArcDrawable extends Drawable {
    private int mFrontArc;
    private int mRearArc;
    private boolean mHas360Arc;
    private final Paint mTransparentPaint = new Paint();
    private final Paint mOpaquePaint = new Paint();
    private final Paint mDashedPaint;
    private final RectF mRectF = new RectF();
    private final int mLineWidth;
    private final int mArrowWidth;
    private final Path mArrowPath = new Path();

    // avoid allocations during draw, assumes single threaded use
    private static final Matrix sTempMatrix = new Matrix();

    private static final int ARROW_DEGREE_OFFSET = 15;

    public ArcDrawable(Resources res) {
        mLineWidth = res.getDimensionPixelSize(R.dimen.maneuver_line_size);
        mArrowWidth = res.getDimensionPixelSize(R.dimen.arc_arrow_size);
        mTransparentPaint.setAntiAlias(true);
        mTransparentPaint.setStyle(Paint.Style.FILL);
        mOpaquePaint.setAntiAlias(true);
        mOpaquePaint.setStyle(Paint.Style.STROKE);
        mOpaquePaint.setStrokeWidth(mLineWidth);

        mDashedPaint = new Paint(mOpaquePaint);
        mDashedPaint.setPathEffect(new DashPathEffect(new float[]{mLineWidth, 2 * mLineWidth}, 0));
        mDashedPaint.setStrokeCap(Paint.Cap.ROUND);
    }

    public void set360Arc(int color) {
        setArcsInternal(color, 0, 0, true);
    }

    public void setArc(int color, int frontArc, int rearArc) {
        setArcsInternal(color, frontArc, rearArc, false);
    }

    private void setArcsInternal(int color, int frontArc, int rearArc, boolean has360Arc) {
        mFrontArc = frontArc;
        mRearArc = rearArc;
        mHas360Arc = has360Arc;
        mTransparentPaint.setColor(color);
        mTransparentPaint.setAlpha(0x80);
        mOpaquePaint.setColor(color);
        mOpaquePaint.setAlpha(0xff);
        mDashedPaint.setColor(color);
        mDashedPaint.setAlpha(0xff);
        invalidateSelf();
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

    private void draw360Arc(Canvas canvas) {
        if (!mHas360Arc) return;

        mRectF.inset(mArrowWidth, mArrowWidth);
        if (mArrowPath.isEmpty()) {
            mArrowPath.moveTo(0.6f, 0);
            mArrowPath.lineTo(0, -1);
            mArrowPath.lineTo(-0.6f, 0);
            mArrowPath.close();

            sTempMatrix.setRotate(ARROW_DEGREE_OFFSET,
                    mRectF.centerX(), mRectF.centerY());
            sTempMatrix.preTranslate(mRectF.right, mRectF.centerY());
            sTempMatrix.preScale(mArrowWidth, mArrowWidth);
            mArrowPath.transform(sTempMatrix);
        }

        mOpaquePaint.setStyle(Paint.Style.FILL);
        canvas.drawPath(mArrowPath, mOpaquePaint);
        mOpaquePaint.setStyle(Paint.Style.STROKE);
        canvas.drawArc(mRectF, ARROW_DEGREE_OFFSET, 360 - ARROW_DEGREE_OFFSET,
                false, mOpaquePaint);
    }

    @Override
    public void draw(Canvas canvas) {
        mRectF.set(getBounds());
        mRectF.inset(mLineWidth, mLineWidth);
        drawArc(canvas, mFrontArc, -90, mTransparentPaint, mOpaquePaint);
        drawArc(canvas, mRearArc, 90, null, mDashedPaint);
        draw360Arc(canvas);
    }

    @Override
    public void setAlpha(int alpha) {}

    @Override
    public void setColorFilter(ColorFilter cf) {}

    @Override
    public int getOpacity() {
        return 0;
    }
}
