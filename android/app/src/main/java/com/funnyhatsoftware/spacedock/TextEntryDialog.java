package com.funnyhatsoftware.spacedock;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.text.InputType;
import android.widget.EditText;
import android.widget.Toast;

public class TextEntryDialog {
    public interface OnAcceptListener {
        /**
         * Called if the Dialog is accepted with non-null, non-empty string input.
         */
        public void onTextValueCommitted(String inputText);
    }

    public static void create(final Context context, String initialText,
            int titleStringResId,
            final int errorEmptyStringResId,
            final OnAcceptListener listener) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(titleStringResId);
        final EditText input = new EditText(context);
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        input.setText(initialText);
        builder.setView(input);

        builder.setPositiveButton(R.string.dialog_accept, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (errorEmptyStringResId == R.string.dialog_error_empty_squad_name) {
                    String inputText = input.getText().toString();
                    if (inputText == null || inputText.isEmpty()) {
                        Toast.makeText(context, errorEmptyStringResId, Toast.LENGTH_SHORT).show();
                    } else {
                        listener.onTextValueCommitted(inputText);
                    }
                } else if (errorEmptyStringResId == R.string.dialog_error_nan) {
                    String inputText = input.getText().toString();
                    try {
                        Integer myNum = new Integer(input.getText().toString());
                        listener.onTextValueCommitted(inputText);
                    } catch (NumberFormatException nfe) {
                        System.out.println("Could not parse " + nfe);
                    }
                } else {
                    String inputText = input.getText().toString();
                    listener.onTextValueCommitted(inputText);
                }
            }
        });
        builder.setNegativeButton(R.string.dialog_reject, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });
        builder.show();
    }
}
