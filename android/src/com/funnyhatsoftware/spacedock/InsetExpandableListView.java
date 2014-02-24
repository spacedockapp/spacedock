package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.widget.ExpandableListView;

public class InsetExpandableListView extends ExpandableListView {
    private final int mShadowWidth;
    private final Drawable mShadowDrawable;

    public InsetExpandableListView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public InsetExpandableListView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        mShadowWidth = getResources().getDimensionPixelSize(R.dimen.inset_shadow_width);
        mShadowDrawable = getResources().getDrawable(R.drawable.inset_shadow);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mShadowDrawable.setBounds(w - mShadowWidth, 0, w, h);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
        mShadowDrawable.draw(canvas);
    }
}
