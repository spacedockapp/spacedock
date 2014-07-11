package com.funnyhatsoftware.spacedock;

import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.data.Universe;

import org.json.JSONException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

/**
 * Collection of helper methods for importing/exporting data
 */
public class DataHelper {
    public static void loadUniverseDataFromUri(Context context, Uri data) {
        boolean success = false;
        try {
            Log.i("spacedock", "want to open " + data.getPath() + " " + data.getScheme());
            String scheme = data.getScheme();
            InputStream is = null;
            if (scheme.equals("file")) {
                File squadFile = new File(data.getPath());
                is = new FileInputStream(squadFile);
            } else if (scheme.equals("content")) {
                is = context.getContentResolver().openInputStream(data);
            }
            Universe.getUniverse().loadSquadsFromStream(is, true);
            is.close();
            success = true;
        } catch (FileNotFoundException e) {
        } catch (JSONException e) {
        } catch (IOException e) {
        }
        if (success) {
            Toast.makeText(context, "Imported squads.", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(context, "Failed to import squads.", Toast.LENGTH_SHORT).show();
        }
    }

    public static void saveUniverseData(Context context) {
        Universe universe = Universe.getUniverse();
        try {
            universe.save(context);
        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(context, "failed to save", Toast.LENGTH_SHORT).show();
        }
    }
}
