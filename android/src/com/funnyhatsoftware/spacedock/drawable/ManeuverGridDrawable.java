package com.funnyhatsoftware.spacedock.drawable;

import java.util.ArrayList;

import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.support.v4.util.ArrayMap;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Maneuver;

public class ManeuverGridDrawable extends Drawable {
    private static final float HEAD_WIDTH = 0.5f;
    private static final float BODY_WIDTH = 0.2f;
    private static final float HEAD_HEIGHT = 0.35f;
    private static Path getStraight() {
        Path path = new Path();
        path.moveTo(-BODY_WIDTH / 2, 1);
        path.lineTo(-BODY_WIDTH / 2, HEAD_HEIGHT);
        path.lineTo(-HEAD_WIDTH / 2, HEAD_HEIGHT);
        path.lineTo(0, 0);
        path.lineTo(HEAD_WIDTH / 2, HEAD_HEIGHT);
        path.lineTo(BODY_WIDTH / 2, HEAD_HEIGHT);
        path.lineTo(BODY_WIDTH / 2, 1);
        return path;
    }
    private static Path getAbout() {
        final RectF rect = new RectF();
        Path path = new Path();
        path.moveTo(-0.35f, 1);
        path.lineTo(-0.35f, 0.5f);
        rect.set(-0.35f, 0.15f, 0.35f, 0.85f);
        path.arcTo(rect, -180, 180);
        path.lineTo(0.35f, 0.65f);
        path.lineTo(0.5f, 0.65f);
        path.lineTo(0.25f, 1);
        path.lineTo(0, 0.65f);
        path.lineTo(0.15f, 0.65f);
        path.lineTo(0.15f, 0.5f);
        rect.set(-0.15f, 0.35f, 0.15f, 0.65f);
        path.arcTo(rect, 0, -180);
        path.lineTo(-0.15f, 1);
        path.lineTo(-0.35f, 1);
        return path;
    }
    private static Path getBank() {
        final float diameter = 1.6f;
        final float theta = 70f;
        final RectF rect = new RectF();
        Path path = new Path();

        // outer arc
        float boxSize = diameter + BODY_WIDTH;
        rect.set(0, 0, boxSize, boxSize);
        rect.offset(-0.3f, 1 - boxSize / 2);
        path.moveTo(-0.3f, 1);
        path.arcTo(rect, 180, theta);

        // inner arc
        boxSize = diameter - BODY_WIDTH;
        rect.set(0, 0, boxSize, boxSize);
        rect.offset((BODY_WIDTH - 0.3f), 1 - boxSize / 2);
        path.arcTo(rect, 180 + theta, -theta);
        path.close();

        // arrow head
        path.moveTo((0.4f - HEAD_HEIGHT), 0.1f);
        path.lineTo(0.5f, 0.2f);
        path.lineTo((0.6f - HEAD_HEIGHT), 0.6f);
        path.close();
        return path;
    }
    private static Path getTurn() {
        Path path = new Path();

        // arrow head
        path.moveTo((0.5f - HEAD_HEIGHT), 0);
        path.lineTo(0.5f, 0.25f);
        path.lineTo((0.5f - HEAD_HEIGHT), 0.5f);
        path.close();

        // body
        path.addRect(-0.35f, 0.15f,
                (0.5f - HEAD_HEIGHT), 0.35f, Path.Direction.CW);
        path.addRect(-0.35f, 0.35f,
                -0.15f, 1, Path.Direction.CW);
        return path;
    }

    private float[] getLines() {
        final int MAX_X = 7;
        final int MAX_Y = 7;
        final float cellOffset = mGridSize + mLineWidth;
        final float yOffset = mGridSize / 2;
        float[] lines = new float[MAX_X * MAX_Y * 4];
        int index = 0;
        for (int x = 0; x < 7; x++) {
            for (int y = 0; y < 7; y++) {
                lines[index++] = x * cellOffset;
                lines[index++] = y * cellOffset + yOffset;
                lines[index++] = x * cellOffset + mGridSize;
                lines[index++] = y * cellOffset + yOffset;
            }
        }
        return lines;
    }

    private ArrayMap<String, Paint> mPaintMap = new ArrayMap<String, Paint>();
    private ArrayMap<String, Path> mPathMap = new ArrayMap<String, Path>();
    private final Paint mLinePaint = new Paint();
    private final int mGridSize;
    private final int mLineWidth;
    private final ArrayList<Maneuver> mManeuvers = new ArrayList<Maneuver>();
    private final float[] mLines;

    private void addPaintColor(String name, int color) {
        Paint paint = new Paint();
        paint.setColor(color);
        paint.setAntiAlias(true);
        mPaintMap.put(name, paint);
    }

    private final int ROTATE_RIGHT_FLAG = 0x1;
    private final int HORIZONTAL_FLIP_FLAG = 0x2;
    private final Matrix mTempMatrix = new Matrix();
    private void addPath(String name, Path p, int flags) {
        mTempMatrix.setScale(mGridSize, mGridSize);
        if ((flags & HORIZONTAL_FLIP_FLAG) != 0) {
            mTempMatrix.preScale(-1, 1);
        }
        if ((flags & ROTATE_RIGHT_FLAG) != 0) {
            mTempMatrix.preRotate(90, 0, 0.5f);
        }
        p.transform(mTempMatrix);
        mPathMap.put(name, p);
    }

    public ManeuverGridDrawable(Resources res) {
        mGridSize = res.getDimensionPixelSize(R.dimen.maneuver_grid_size);
        mLineWidth = res.getDimensionPixelSize(R.dimen.maneuver_line_size);
        mLines = getLines();

        // paint setup
        mLinePaint.setStrokeWidth(mGridSize);
        mLinePaint.setColor(Color.LTGRAY);
        addPaintColor("red", res.getColor(R.color.dark_red));
        addPaintColor("green", res.getColor(R.color.dark_green));
        addPaintColor("white", Color.WHITE);
        addPath("straight", getStraight(), 0);
        addPath("right-bank", getBank(), 0);
        addPath("right-spin", getStraight(), ROTATE_RIGHT_FLAG);
        addPath("left-bank", getBank(), HORIZONTAL_FLIP_FLAG);
        addPath("left-spin", getStraight(), HORIZONTAL_FLIP_FLAG | ROTATE_RIGHT_FLAG);
        addPath("right-turn", getTurn(), 0);
        addPath("left-turn", getTurn(), HORIZONTAL_FLIP_FLAG);
        addPath("about", getAbout(), 0);
    }

    private int getHorizontalPosition(String kind) {
        if (kind.equals("straight")) return 0;
        if (kind.equals("right-bank") || kind.equals("right-spin")) return 1;
        if (kind.equals("left-bank") || kind.equals("left-spin")) return -1;
        if (kind.equals("right-turn")) return 2;
        if (kind.equals("left-turn")) return -2;
        if (kind.equals("about")) return 3;

        return Integer.MAX_VALUE; // unknown kind of movement
    }

    public void setManeuvers(ArrayList<Maneuver> maneuvers) {
        mManeuvers.clear();
        if (maneuvers != null) {
            mManeuvers.addAll(maneuvers);
        }
    }

    @Override
    public int getIntrinsicWidth() {
        return mGridSize * 7 + mLineWidth;
    }

    @Override
    public int getIntrinsicHeight() {
        return mGridSize * 7 + mLineWidth;
    }

    @Override
    public void draw(Canvas canvas) {
        // TODO: scaling if not intrinsically sized?
        canvas.drawLines(mLines, mLinePaint);
        final float cellOffset = mGridSize + mLineWidth;
        final float xOffset = 3.5f * cellOffset - mLineWidth / 2;
        final float yOffset = 5f * cellOffset;
        for (int i = 0; i < mManeuvers.size(); i++) {
            int save = canvas.save(Canvas.MATRIX_SAVE_FLAG);
            Maneuver m = mManeuvers.get(i);
            int column = getHorizontalPosition(m.getKind());
            int speed = m.getSpeed();
            canvas.translate(column * cellOffset + xOffset,
                    -speed * cellOffset + yOffset);
            if (speed < 0) {
                canvas.translate(0, -mLineWidth);
                canvas.scale(1, -1);
            }
            canvas.drawPath(mPathMap.get(m.getKind()), mPaintMap.get(m.getColor()));
            canvas.restoreToCount(save);
        }
    }

    @Override
    public void setAlpha(int alpha) {
        for (Paint p : mPaintMap.values()) {
            p.setAlpha(alpha);
        }
    }

    @Override
    public void setColorFilter(ColorFilter cf) {
        for (Paint p : mPaintMap.values()) {
            p.setColorFilter(cf);
        }
    }

    @Override
    public int getOpacity() {
        return 0;
    }
}
