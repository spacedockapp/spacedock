package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.DetailActivity;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class ResourceHolder extends ItemHolder {
    public static final String TYPE_STRING = "Resource";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(TYPE_STRING, R.layout.resource_list_row, 0) {
            @Override
            public boolean usesFactions() {
                return false;
            }

            @Override
            public ItemHolder createHolder(View view) {
                return new ResourceHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getResources();
            }

            @Override
            public String getDetails(DetailActivity.DetailDataBuilder builder, String id) {
                Resource resource = Universe.getUniverse().getResource(id);
                builder.addString("Name", resource.getTitle());
                builder.addInt("Cost", resource.getCost());
                builder.addString("Ability", resource.getAbility());
                return resource.getTitle();
            }
        };
    }

    final TextView mTitle;
    final TextView mCost;

    private ResourceHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.resourceRowTitle);
        mCost = (TextView) view.findViewById(R.id.resourceRowCost);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Resource resource = (Resource) item;
        mTitle.setText(resource.getTitle());
        mCost.setText(Integer.toString(resource.getCost()));
    }
}
