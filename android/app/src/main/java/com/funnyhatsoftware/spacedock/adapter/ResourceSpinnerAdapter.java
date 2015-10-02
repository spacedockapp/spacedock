package com.funnyhatsoftware.spacedock.adapter;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.ArrayList;

public class ResourceSpinnerAdapter extends ArrayAdapter<ResourceSpinnerAdapter.ResourceWrapper>
        implements AdapterView.OnItemSelectedListener {
    public interface ResourceSelectListener {
        public void onResourceChanged(Resource previousResource, Resource selectedResource);
    }

    /**
     * Creates a ResourceSpinnerAdapter, and binds it to the provided spinner
     *
     * @param activity Provides the context, must also implement ResourceSelectListener
     * @param resourceSpinner Spinner to initialize with adapter/data
     * @param squad The resource of this squad is managed by the created adapter
     */
    public static void createForSpinner(Activity activity, Spinner resourceSpinner, Squad squad) {
        ResourceSpinnerAdapter resourceAdapter = new ResourceSpinnerAdapter(activity, squad);
        resourceSpinner.setAdapter(resourceAdapter);
        resourceSpinner.setSelection(resourceAdapter.getPositionOfResource(squad.getResource()));
        resourceSpinner.setOnItemSelectedListener(resourceAdapter);
    }

    protected static class ResourceWrapper {
        final Resource mResource;
        final String mLabel;

        public ResourceWrapper(Context context, Resource resource, Squad squad) {
            mResource = resource;
            if (mResource == null) {
                mLabel = context.getResources().getString(R.string.no_resource);
            } else {
                mLabel = resource.equippedIntoSquad(squad)
                        ? mResource.getTitle() // cost built into Squad when used
                        : mResource.getTitle() + " (" + mResource.getCostForSquad(squad) + ")";
            }
        }

        @Override
        public String toString() { return mLabel; }
    }

    private final Squad mSquad;
    private final ResourceSelectListener mListener;

    private static ArrayList<ResourceWrapper> getResources(Context context, Squad squad) {
        ArrayList<ResourceWrapper> list = new ArrayList<ResourceWrapper>();

        list.add(new ResourceWrapper(context, null, squad));
        for (Resource r : Universe.getUniverse().getResources()) {
            list.add(new ResourceWrapper(context, r, squad));
        }
        return list;
    }


    private ResourceSpinnerAdapter(Activity activity, Squad squad) {
        super(activity, android.R.layout.simple_spinner_dropdown_item, getResources(activity, squad));
        mSquad = squad;
        mListener = (ResourceSelectListener) activity;
    }

    private int getPositionOfResource(Resource resource) {
        if (resource == null) return 0;
        for (int i = 1; i < getCount(); i++) {
            Resource universeResource = getItem(i).mResource;
            if (resource == universeResource
                    || (resource.getIsFlagship() && universeResource.getIsFlagship())
                    || (resource.isFleetCaptain() && universeResource.isFleetCaptain()))
                return i;
        }
        throw new IllegalStateException("Resource " + resource.getTitle() + " could not be found");
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        Resource previousResource = mSquad.getResource();
        Resource selectedResource = getItem(position).mResource;
        if (previousResource != selectedResource) {
            mSquad.setResource(selectedResource);
            mListener.onResourceChanged(previousResource, selectedResource);
        }
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {}

}
