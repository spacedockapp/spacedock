package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

/**
 * Maps SetItem data to views
 */
public abstract class ItemHolder {
    public abstract void reinitialize(Resources res, Object item);

    protected static void setPositiveIntegerText(TextView textView, int value) {
        if (value > 0) {
            textView.setText(Integer.toString(value));
            textView.setVisibility(View.VISIBLE);
        } else {
            textView.setText(null);
            textView.setVisibility(View.INVISIBLE);
        }
    }
}
