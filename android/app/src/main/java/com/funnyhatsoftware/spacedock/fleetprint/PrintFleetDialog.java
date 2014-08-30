package com.funnyhatsoftware.spacedock.fleetprint;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Bundle;
import android.print.PrintAttributes;
import android.print.PrintManager;
import android.view.LayoutInflater;
import android.widget.DatePicker;
import android.widget.EditText;

@TargetApi(Build.VERSION_CODES.KITKAT)
public class PrintFleetDialog extends DialogFragment {
		private String mSquadUuid;
	
		public PrintFleetDialog() {

		}
		
		
		public static PrintFleetDialog newInstance(String squad_uuid) {
			PrintFleetDialog frag = new PrintFleetDialog();
			Bundle args = new Bundle();
			args.putString("title", "Print Fleet Build Sheet");
			args.putString("squad_uuid", squad_uuid);
			frag.setArguments(args);
			return frag;
		}
				
		@Override
		public Dialog onCreateDialog(Bundle savedInstanceState) {
			super.onCreateDialog(savedInstanceState);
			this.mSquadUuid = getArguments().getString("squad_uuid");
			if ( Build.VERSION.SDK_INT < 19 )
			{
				return new AlertDialog.Builder(getActivity())
				.setTitle("Sorry.")
				.setCancelable(true)
				.setMessage("Printing is not available on this version of Android.\nPlease update to 4.4 or newer.")
				.setNeutralButton(android.R.string.ok,new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                    	PrintFleetDialog.this.getDialog().dismiss();
                    }
                }
            )
            .create();
			
			}
			else {
				AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
				LayoutInflater inflater = getActivity().getLayoutInflater();
				builder.setView(inflater.inflate(R.layout.printfleet_dialog,null))
					.setPositiveButton(R.string.print, new DialogInterface.OnClickListener() {
						@Override
			            public void onClick(DialogInterface dialog, int id) {
							String name = ((EditText) getDialog().findViewById(R.id.name_input)).getText().toString();
							String email = ((EditText) getDialog().findViewById(R.id.email_input)).getText().toString();
							String faction = ((EditText) getDialog().findViewById(R.id.faction_input)).getText().toString();
							String event = ((EditText) getDialog().findViewById(R.id.event_input)).getText().toString();
							DatePicker date = (DatePicker) getDialog().findViewById(R.id.event_date);
							String dates = String.format("%02d-%02d-%04d", date.getMonth()+1, date.getDayOfMonth(), date.getYear());
							
					    	Squad squad = Universe.getUniverse().getSquadByUUID(mSquadUuid);			    	
					    	PrintManager printmanager = (PrintManager) getActivity().getSystemService(Context.PRINT_SERVICE);
					    	String jobname = squad.getName();
					    	
					    	PrintAttributes attribs = new PrintAttributes.Builder()
					    			.setMediaSize(PrintAttributes.MediaSize.NA_LETTER.asPortrait())
					    			.build();
					    	
					    	printmanager.print(jobname, new PrintFleetAdapter(null,squad,name,email,faction,event,dates), attribs);
						}
					})
					.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int id) {
							PrintFleetDialog.this.getDialog().cancel();
						}
					});
				
				return builder.create();
			}
		}
		
}
