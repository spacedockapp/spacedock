package com.funnyhatsoftware.spacedock.holder;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.data.SetItem;

/**
 * Maps SetItem data to views
 */
public abstract class ItemHolder {
    public void navigateToDetailsActivity(Context context, SetItem item, Class activityClass) {
        String id = item.getExternalId();
        Intent intent = new Intent(context, activityClass);
        intent.putExtra("externalId", id);
        context.startActivity(intent);
    }
    public abstract void reinitialize(Resources res, Object item);
    public abstract void navigateToDetails(Context context, Object item);

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
