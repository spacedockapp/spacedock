package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.view.ViewStub;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.SetItem;

/**
 * Maps SetItem data to views
 */
public abstract class SetItemHolder {
    final TextView mUnique;
    final TextView mTitle;
    final TextView mCost;
    final TextView mAbility; // complex only

    protected SetItemHolder(View view) {
        this(view, 0);
    }

    protected SetItemHolder(View view, int stubReplaceLayoutId) {
        this(view, stubReplaceLayoutId, 0);
    }

    protected SetItemHolder(View view,
                            int stubReplaceLayoutId, int stubDetailReplaceLayoutId) {
        mUnique = (TextView) view.findViewById(R.id.unique);
        mTitle = (TextView) view.findViewById(R.id.title);
        mCost = (TextView) view.findViewById(R.id.cost);
        mAbility = (TextView) view.findViewById(R.id.ability);

        if (stubReplaceLayoutId != 0) {
            ViewStub stub = (ViewStub) view.findViewById(R.id.stub_values);
            stub.setLayoutResource(stubReplaceLayoutId);
            stub.inflate();
        }
        if (stubDetailReplaceLayoutId != 0) {
            ViewStub stub = (ViewStub) view.findViewById(R.id.stub_detail_row);
            if (stub != null) {
                stub.setLayoutResource(stubDetailReplaceLayoutId);
                stub.inflate();
            }
        }
    }

    public final void reinitialize(Resources res, Object item) {
        SetItem setItem = (SetItem) item;

        if (setItem.getUnique()) {
            mUnique.setText(R.string.indicator_unique);
        } else {
            mUnique.setText(null);
        }

        mTitle.setText(setItem.getTitle());
        mCost.setText(Integer.toString(setItem.getCost()));

        if (mAbility != null) {
            String ability = setItem.getAbility();
            boolean hasAbility = ability != null && !ability.isEmpty();
            mAbility.setText(ability);
            mAbility.setVisibility(hasAbility ? View.VISIBLE : View.GONE);
        }

        reinitializeStubViews(res, setItem);
    }

    public abstract void reinitializeStubViews(Resources res, SetItem item);

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
