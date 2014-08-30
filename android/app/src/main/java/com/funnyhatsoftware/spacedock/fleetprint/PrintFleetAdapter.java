package com.funnyhatsoftware.spacedock.fleetprint;

import java.io.FileOutputStream;
import java.io.IOException;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.EquippedShip;
import com.funnyhatsoftware.spacedock.data.EquippedUpgrade;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Upgrade;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Typeface;
import android.graphics.pdf.PdfDocument;
import android.graphics.pdf.PdfDocument.PageInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.print.PageRange;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintDocumentInfo;
import android.print.pdf.PrintedPdfDocument;

@TargetApi(Build.VERSION_CODES.KITKAT)
public class PrintFleetAdapter extends PrintDocumentAdapter {

	
	Context context;
	Squad squad;

	public PdfDocument mPdfDocument;
	public int totalpages;
	private int pageHeight;
	private int pageWidth;
	private String name,email,faction,event,date;
	
	public PrintFleetAdapter(Context context,Squad aSquad,String aName,String aEmail,String aFaction,String aEvent,String aDate)
	{
		this.context = context;
		this.squad = aSquad;
		this.name = aName;
		this.email = aEmail;
		this.faction = aFaction;
		this.event = aEvent;
		this.date = aDate;
		
		if ( squad.getEquippedShips().size() > 4 )
		{
			int ships = squad.getEquippedShips().size() - 4;
			totalpages = (int) Math.ceil(ships/6.0);
			totalpages ++;
		}
		else
			totalpages = 1;
		
	}
	
	@Override
	public void onLayout(PrintAttributes oldAttributes,
			PrintAttributes newAttributes,
			CancellationSignal cancellationSignal,
			LayoutResultCallback callback, Bundle extras) {
		
		
		mPdfDocument = new PrintedPdfDocument(context, newAttributes);
		pageHeight = (int) (newAttributes.getMediaSize().getHeightMils()/1000.00 * 72);
		pageWidth = (int) (newAttributes.getMediaSize().getWidthMils()/1000.00 * 72);

		if (cancellationSignal.isCanceled() ) {
			callback.onLayoutCancelled();
			return;
		}
		
		if (totalpages > 0) {
			   PrintDocumentInfo.Builder builder = new PrintDocumentInfo
				  .Builder("fleet_build.pdf")
				  .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
				  .setPageCount(totalpages);
				                
			   PrintDocumentInfo info = builder.build();
			   callback.onLayoutFinished(info, true);
		} else {
			   callback.onLayoutFailed("Page count is zero.");
		}
	}

	@Override
	public void onWrite(PageRange[] pages, ParcelFileDescriptor destination,
			CancellationSignal cancellationSignal, WriteResultCallback callback) {
		
		for (int i = 0; i < totalpages; i++) {
			if (pageInRange(pages, i))
		   	{
			     PageInfo newPage = new PageInfo.Builder(pageWidth, 
	                         pageHeight, i).create();
			    	
			     PdfDocument.Page page = 
	                          mPdfDocument.startPage(newPage);

			     if (cancellationSignal.isCanceled()) {
				  callback.onWriteCancelled();
				  mPdfDocument.close();
				  mPdfDocument = null;
				  return;
			     }
			     drawPage(page, i);
			     mPdfDocument.finishPage(page);  
			}
		}
		    
		try {
			mPdfDocument.writeTo(new FileOutputStream(
			            destination.getFileDescriptor()));
		} catch (IOException e) {
			callback.onWriteFailed(e.toString());
			return;
		} finally {
			mPdfDocument.close();
			mPdfDocument = null;
		}

		callback.onWriteFinished(pages);
		
	}
	
	private void drawPage(PdfDocument.Page page, int pagenumber) {
	    Canvas canvas = page.getCanvas();
	    //PageInfo pageInfo = page.getInfo();
	    Paint paint = new Paint();

	    pagenumber++; // Make sure page numbers start at 1
	    if ( pagenumber > 1 )
	    {
		    paint.setColor(Color.BLACK);
		    
		    canvas.drawLine(18, 18, pageWidth - 18, 18, paint);
		    canvas.drawLine(18, 18, 18, pageHeight - 40, paint); 
		    canvas.drawLine(pageWidth - 18, 18, pageWidth - 18, pageHeight - 40, paint);
		    canvas.drawLine(18, pageHeight - 40, pageWidth - 18, pageHeight - 40, paint);
		    
		    float sBoxW = (float)(pageWidth * 0.435);
		    
		    float boxY = 34;
		    float boxX = 34;
		    //Box 1
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);

			boxX = pageWidth-34-sBoxW;
			//Box 2
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);
			
			boxX = 34;
			boxY += 168;
			//Box 3
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);

			boxX = pageWidth-34-sBoxW;
			//Box 4
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);

			boxX = 34;
			boxY += 168;
			//Box 5
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);

			boxX = pageWidth-34-sBoxW;
			//Box 6
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);
			
			boxX = 34;
			boxY += 168;
			//Box 7
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);

			boxX = pageWidth-34-sBoxW;
			//Box 8
		    paint.setColor(Color.BLACK);
		    canvas.drawLine(boxX,boxY,boxX+sBoxW,boxY, paint);
		    canvas.drawLine(boxX,boxY,boxX,boxY+132, paint);
		    canvas.drawLine(boxX+sBoxW,boxY,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+132,boxX+(float)(sBoxW*.85),boxY+152, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY+152,boxX+sBoxW,boxY+152, paint);
		    canvas.drawLine(boxX,boxY+132,boxX+sBoxW,boxY+132, paint);
		    paint.setColor(Color.GRAY);
		    canvas.drawLine(boxX+(float)(sBoxW*.15),boxY,boxX+(float)(sBoxW*.15),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.70),boxY,boxX+(float)(sBoxW*.70),boxY+132, paint);
		    canvas.drawLine(boxX+(float)(sBoxW*.85),boxY,boxX+(float)(sBoxW*.85),boxY+132, paint);
		    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
		    {
		    	canvas.drawLine(boxX,boxY+(lineNo*11),boxX+sBoxW,boxY+(lineNo*11), paint);
		    }
		    paint.setTextSize(10);
		    paint.setColor(Color.BLACK);
			paint.setTextAlign(Align.CENTER);
			canvas.drawText("Type", boxX + (float)(sBoxW*.075), boxY + 10, paint);
			canvas.drawText("Card Title", boxX + (float)(sBoxW*.425), boxY + 10, paint);
			canvas.drawText("Faction", boxX + (float)(sBoxW*.775), boxY + 10, paint);
			canvas.drawText("SP", boxX + (float)(sBoxW*.925), boxY + 10, paint);
		    
    		float x = 35,y = 44;

		    if ( squad.getEquippedShips().size() >= ((pagenumber*8) - 8 - 4) )
		    {
		    	int shipNo = 1;
		    	for ( EquippedShip ship : squad.getEquippedShips() )
		    	{
		    		if ( shipNo <= ((pagenumber*8) - 8 - 4) || shipNo > ((pagenumber*8) - 4 ) )
		    		{	
		    			shipNo++;
		    			continue;
		    		}
		    	    paint.setTextSize(9);

		    		int upgNo = 1;
		    		if ( shipNo == 1 ) { x = 35; y = 170; }
		    		if ( shipNo == 2 ) { x = pageWidth-33-sBoxW; y = 170; }
		    		if ( shipNo == 3 ) { x = 35; y = 338; }
		    		if ( shipNo == 4 ) { x = pageWidth-33-sBoxW; y = 338; }
		    		
		    	    paint.setTextAlign(Align.LEFT);
		    		canvas.drawText("Ship", x, y+(11*upgNo), paint);
		    		canvas.drawText(ship.getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
		    		paint.setTextAlign(Align.CENTER);
		    		canvas.drawText(ship.getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
		    	    paint.setTextAlign(Align.RIGHT);
		    		canvas.drawText(Integer.toString(ship.getBaseCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
		    		upgNo ++;
		    		
		    		if ( ship.getFlagship() != null )
		    		{
			    	    paint.setTextAlign(Align.LEFT);
			    		canvas.drawText("Flag", x, y+(11*upgNo), paint);
			    		canvas.drawText(ship.getFlagship().getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
			    		paint.setTextAlign(Align.CENTER);
			    		canvas.drawText(ship.getFlagship().getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
			    	    paint.setTextAlign(Align.RIGHT);
			    		canvas.drawText(Integer.toString(ship.getFlagship().getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
			    		upgNo ++;
		    		}
		    		
		    		Captain cap = ship.getCaptain();
		    		paint.setTextAlign(Align.LEFT);
		    		canvas.drawText("Captain", x, y+(11*upgNo), paint);
		    		canvas.drawText(cap.getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
		    		paint.setTextAlign(Align.CENTER);
		    		canvas.drawText(cap.getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
		    	    paint.setTextAlign(Align.RIGHT);
		    		canvas.drawText(Integer.toString(cap.getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
		    		upgNo ++;
		    		
		    		if ( ship.getFleetCaptain() != null )
		    		{
			    	    paint.setTextAlign(Align.LEFT);
			    		canvas.drawText("FleetCap", x, y+(11*upgNo), paint);
			    		canvas.drawText(ship.getFleetCaptain().getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
			    		paint.setTextAlign(Align.CENTER);
			    		canvas.drawText(ship.getFleetCaptain().getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
			    	    paint.setTextAlign(Align.RIGHT);
			    		canvas.drawText(Integer.toString(ship.getFleetCaptain().getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
			    		upgNo ++;
		    		}
		    		
		    		
		    		for ( EquippedUpgrade anUpg : ship.getAllUpgradesExceptPlaceholders() )
		    		{
		    			Upgrade theUpg = anUpg.getUpgrade();
		    			if ( anUpg.isCaptain() ) continue;
		    			if ( theUpg.isPlaceholder() ) continue;
		    			
			    		paint.setTextAlign(Align.CENTER);
			    		if ( !theUpg.isTalent() ) canvas.drawText(theUpg.getUpType().substring(0,1), x + (float)(sBoxW*.075), y+(11*upgNo), paint);
			    		if ( theUpg.isTalent() ) canvas.drawText("E".substring(0,1), x + (float)(sBoxW*.075), y+(11*upgNo), paint);
			    		paint.setTextAlign(Align.LEFT);
			    		canvas.drawText(theUpg.getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
			    		paint.setTextAlign(Align.CENTER);
			    		canvas.drawText(theUpg.getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
			    	    paint.setTextAlign(Align.RIGHT);
			    		canvas.drawText(Integer.toString(theUpg.getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
			    		upgNo ++;
		    		}

		    	    paint.setTextSize(14);
		    		paint.setTextAlign(Align.CENTER);

		    		canvas.drawText(Integer.toString(ship.calculateCost()), (float) (x + (sBoxW*.925)), y+138, paint);
		    		
		    		if ( x == 35 )
		    		{
		    			x = pageWidth-33-sBoxW;
		    		}
		    		else
		    		{
		    			x = 35;
		    			y += 168;
		    		}
		    		shipNo ++;
		    	}
		    }
		    
		    
		    return;
	    }

	    paint.setColor(Color.BLACK);
	    
	    canvas.drawLine(18, 18, pageWidth - 18, 18, paint);
	    canvas.drawLine(18, 18, 18, pageHeight - 40, paint); 
	    canvas.drawLine(pageWidth - 18, 18, pageWidth - 18, pageHeight - 40, paint);
	    canvas.drawLine(18, pageHeight - 40, pageWidth - 18, pageHeight - 40, paint);
	    
	    canvas.drawRect(18, 18, pageWidth - 18, 76, paint);
	    
	    paint.setColor(Color.GRAY);
	    canvas.drawRect(18, pageHeight - 168, pageWidth - 18, pageHeight - 40, paint);
	    
	    paint.setColor(Color.WHITE);
	    paint.setTextSize(24);
	    paint.setTextAlign(Align.CENTER);
	    
	    canvas.drawText("Fleet Build Sheet",pageWidth/2,56,paint);
	    
	    paint.setColor(Color.BLACK);
	    paint.setTextSize(14);
	    paint.setTextAlign(Align.RIGHT);
	    paint.setTypeface(Typeface.DEFAULT);
	    
	    canvas.drawText("Date:", 88, 98, paint);
	    canvas.drawText("Event:", 88, 123, paint);
	    canvas.drawText("Faction:", 88, 147, paint);
	    
	    canvas.drawText("Name:", pageWidth-18-15-164-9, 98, paint);
	    canvas.drawText("Email:", pageWidth-18-15-164-9, 123, paint);
	    
	    //paint.setStrokeWidth(1);
	    canvas.drawRect(97, 82, 97+164, 103, paint);
	    canvas.drawRect(97, 107, 97+164, 128, paint);
	    canvas.drawRect(97, 132, 97+164, 152, paint);
	    canvas.drawRect(pageWidth-18-15-164, 82, pageWidth-34, 103, paint);
	    canvas.drawRect(pageWidth-18-15-164, 107, pageWidth-34, 128, paint);

	    //paint.setStrokeWidth(0);
	    paint.setColor(Color.WHITE);
	    canvas.drawRect(98, 83, 98+162, 102, paint);
	    canvas.drawRect(98, 108, 98+162, 127, paint);
	    canvas.drawRect(98, 133, 98+162, 151, paint);
	    canvas.drawRect(pageWidth-18-15-163, 83, pageWidth-35, 102, paint);
	    canvas.drawRect(pageWidth-18-15-163, 108, pageWidth-35, 127, paint);

	    float sBoxW = (float)(pageWidth * 0.435);
	    //Box 1
	    paint.setColor(Color.BLACK);
	    canvas.drawLine(34,160,34+sBoxW,160, paint);
	    canvas.drawLine(34,160,34,160+132, paint);
	    canvas.drawLine(34+sBoxW,160,34+sBoxW,160+152, paint);
	    canvas.drawLine(34+(float)(sBoxW*.85),160+132,34+(float)(sBoxW*.85),160+152, paint);
	    canvas.drawLine(34+(float)(sBoxW*.85),160+152,34+sBoxW,160+152, paint);
	    canvas.drawLine(34,160+132,34+sBoxW,160+132, paint);
	    paint.setColor(Color.GRAY);
	    canvas.drawLine(34+(float)(sBoxW*.15),160,34+(float)(sBoxW*.15),160+132, paint);
	    canvas.drawLine(34+(float)(sBoxW*.70),160,34+(float)(sBoxW*.70),160+132, paint);
	    canvas.drawLine(34+(float)(sBoxW*.85),160,34+(float)(sBoxW*.85),160+132, paint);
	    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
	    {
	    	canvas.drawLine(34,160+(lineNo*11),34+sBoxW,160+(lineNo*11), paint);
	    }
	    //Box 2
	    paint.setColor(Color.BLACK);
	    canvas.drawLine(pageWidth-34-sBoxW,160,pageWidth-34,160, paint);
	    canvas.drawLine(pageWidth-34-sBoxW,160,pageWidth-34-sBoxW,160+132, paint);
	    canvas.drawLine(pageWidth-34,160,pageWidth-34,160+152, paint);
	    canvas.drawLine(pageWidth-34-(float)(sBoxW*.15),160+132,pageWidth-34-(float)(sBoxW*.15),160+152, paint);
	    canvas.drawLine(pageWidth-34-(float)(sBoxW*.15),160+152,pageWidth-34,160+152, paint);
	    canvas.drawLine(pageWidth-34-sBoxW,160+132,pageWidth-34,160+132, paint);
	    paint.setColor(Color.GRAY);
	    canvas.drawLine(pageWidth-34-sBoxW+(float)(sBoxW*.15),160,pageWidth-34-sBoxW+(float)(sBoxW*.15),160+132, paint);
	    canvas.drawLine(pageWidth-34-sBoxW+(float)(sBoxW*.70),160,pageWidth-34-sBoxW+(float)(sBoxW*.70),160+132, paint);
	    canvas.drawLine(pageWidth-34-sBoxW+(float)(sBoxW*.85),160,pageWidth-34-sBoxW+(float)(sBoxW*.85),160+132, paint);
	    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
	    {
		    canvas.drawLine(pageWidth-34-sBoxW,160+(lineNo*11),pageWidth-34,160+(lineNo*11), paint);
	    }
	    //Box 3
	    paint.setColor(Color.BLACK);
	    canvas.drawLine(34,328,34+sBoxW,328, paint);
	    canvas.drawLine(34,328,34,328+132, paint);
	    canvas.drawLine(34+sBoxW,328,34+sBoxW,328+152, paint);
	    canvas.drawLine(34+(float)(sBoxW*.85),328+132,34+(float)(sBoxW*.85),328+152, paint);
	    canvas.drawLine(34+(float)(sBoxW*.85),328+152,34+sBoxW,328+152, paint);
	    canvas.drawLine(34,328+132,34+sBoxW,328+132, paint);
	    paint.setColor(Color.GRAY);
	    canvas.drawLine(34+(float)(sBoxW*.15),328,34+(float)(sBoxW*.15),328+132, paint);
	    canvas.drawLine(34+(float)(sBoxW*.70),328,34+(float)(sBoxW*.70),328+132, paint);
	    canvas.drawLine(34+(float)(sBoxW*.85),328,34+(float)(sBoxW*.85),328+132, paint);
	    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
	    {
	    	canvas.drawLine(34,328+(lineNo*11),34+sBoxW,328+(lineNo*11), paint);
	    }
	    //Box 4
	    paint.setColor(Color.BLACK);
	    canvas.drawLine(pageWidth-34-sBoxW,328,pageWidth-34,328, paint);
	    canvas.drawLine(pageWidth-34-sBoxW,328,pageWidth-34-sBoxW,328+132, paint);
	    canvas.drawLine(pageWidth-34,328,pageWidth-34,328+152, paint);
	    canvas.drawLine(pageWidth-34-(float)(sBoxW*.15),328+132,pageWidth-34-(float)(sBoxW*.15),328+152, paint);
	    canvas.drawLine(pageWidth-34-(float)(sBoxW*.15),328+152,pageWidth-34,328+152, paint);
	    canvas.drawLine(pageWidth-34-sBoxW,328+132,pageWidth-34,328+132, paint);
	    paint.setColor(Color.GRAY);
	    canvas.drawLine(pageWidth-34-sBoxW+(float)(sBoxW*.15),328,pageWidth-34-sBoxW+(float)(sBoxW*.15),328+132, paint);
	    canvas.drawLine(pageWidth-34-sBoxW+(float)(sBoxW*.70),328,pageWidth-34-sBoxW+(float)(sBoxW*.70),328+132, paint);
	    canvas.drawLine(pageWidth-34-sBoxW+(float)(sBoxW*.85),328,pageWidth-34-sBoxW+(float)(sBoxW*.85),328+132, paint);
	    for ( int lineNo = 1; lineNo < 12; lineNo ++ )
	    {
		    canvas.drawLine(pageWidth-34-sBoxW,328+(lineNo*11),pageWidth-34,328+(lineNo*11), paint);
	    }

	    paint.setColor(Color.BLACK);
	    canvas.drawRect(34, 495, pageWidth-34, 537, paint);
	    paint.setColor(Color.WHITE);
	    canvas.drawRect(35, 496, pageWidth-35, 536, paint);

	    paint.setColor(Color.BLACK);
	    canvas.drawRect(138, 546, pageWidth-120, 569, paint);
	    paint.setColor(Color.WHITE);
	    canvas.drawRect(139, 547, pageWidth-121, 568, paint);
	    
	    paint.setColor(Color.BLACK);
	    canvas.drawRect(pageWidth-68, 546, pageWidth-34, 569, paint);
	    paint.setColor(Color.WHITE);
	    canvas.drawRect(pageWidth-67, 547, pageWidth-35, 568, paint);

	    paint.setColor(Color.BLACK);
	    paint.setTextAlign(Align.LEFT);
	    canvas.drawText("Resource Used:", 34, 563, paint);
	    canvas.drawText("SP", pageWidth-88, 563, paint);
	    
	    paint.setColor(Color.BLACK);
	    canvas.drawRect(34, 577, pageWidth-34, 613, paint);
	    paint.setColor(Color.WHITE);
	    canvas.drawRect(35, 578, pageWidth-35, 612, paint);
	    paint.setColor(Color.BLACK);
	    float tW = (float)(pageWidth-68)/7;
	    canvas.drawLine(34,593,pageWidth-34,593, paint);
	    for ( int i = 1; i<7; i++ )
	    {
	    	canvas.drawLine(34+(float)(tW*i), 577, 34+(float)(tW*i), 613, paint);
	    }
	    paint.setTextSize(10);
	    paint.setTextAlign(Align.CENTER);
	    canvas.drawText("Ship 1", 34+(float)((tW*1)-(tW/2)), 589, paint);
	    canvas.drawText("Ship 2", 34+(float)((tW*2)-(tW/2)), 589, paint);
	    canvas.drawText("Ship 3", 34+(float)((tW*3)-(tW/2)), 589, paint);
	    canvas.drawText("Ship 4", 34+(float)((tW*4)-(tW/2)), 589, paint);
	    canvas.drawText("Resource", 34+(float)((tW*5)-(tW/2)), 589, paint);
	    canvas.drawText("Other", 34+(float)((tW*6)-(tW/2)), 589, paint);
	    canvas.drawText("Total", 34+(float)((tW*7)-(tW/2)), 589, paint);

	    paint.setTextSize(16);
	    canvas.drawText("Before Battle Starts:", 34+(sBoxW/2), 645, paint);
	    canvas.drawText("After Battle Ends:", pageWidth-34-(sBoxW/2), 645, paint);
	    
	    paint.setColor(Color.BLACK);
	    canvas.drawRect(34, 650, 34+sBoxW, pageHeight-60, paint);
	    paint.setColor(Color.WHITE);
	    canvas.drawRect(35, 651, 33+sBoxW, pageHeight-61, paint);
	    paint.setColor(Color.GRAY);
	    canvas.drawLine(34, pageHeight-108, 34+sBoxW, pageHeight-108, paint);
	    canvas.drawLine(34, pageHeight-92, 34+sBoxW, pageHeight-92, paint);
	    canvas.drawLine(34, pageHeight-76, 34+sBoxW, pageHeight-76, paint);
	    canvas.drawLine(34+(float)(sBoxW*.15), 650, 34+(float)(sBoxW*.15), pageHeight-60, paint);
	    canvas.drawLine(34+(float)(sBoxW*.80), 650, 34+(float)(sBoxW*.80), pageHeight-60, paint);
	    paint.setColor(Color.BLACK);
	    paint.setTextSize(7);
	    paint.setTextAlign(Align.CENTER);
	    canvas.drawText("Battle", 34+(float)(sBoxW*.075), 665, paint );
	    canvas.drawText("Round", 34+(float)(sBoxW*.075), 675, paint );
	    canvas.drawText("Opponent's Name", 34+(float)((sBoxW*.15)+(sBoxW*.325)), 670, paint );
	    canvas.drawText("Opponent's", 34+(float)(sBoxW*.9), 660, paint );
	    canvas.drawText("Initials", 34+(float)(sBoxW*.9), 670, paint );
	    paint.setTextSize(6);
	    canvas.drawText("(Verify Build)", 34+(float)(sBoxW*.9), 680, paint );
	    
	    paint.setColor(Color.BLACK);
	    canvas.drawRect(pageWidth-34-sBoxW, 650, pageWidth-34, pageHeight-60, paint);
	    paint.setColor(Color.WHITE);
	    canvas.drawRect(pageWidth-33-sBoxW, 651, pageWidth-35, pageHeight-61, paint);
	    paint.setColor(Color.GRAY);
	    canvas.drawLine(pageWidth-34, pageHeight-108, pageWidth-34-sBoxW, pageHeight-108, paint);
	    canvas.drawLine(pageWidth-34, pageHeight-92, pageWidth-34-sBoxW, pageHeight-92, paint);
	    canvas.drawLine(pageWidth-34, pageHeight-76, pageWidth-34-sBoxW, pageHeight-76, paint);
	    canvas.drawLine(pageWidth-34-(float)(sBoxW*.75), 650, pageWidth-34-(float)(sBoxW*.75), pageHeight-60, paint);
	    canvas.drawLine(pageWidth-34-(float)(sBoxW*.50), 650, pageWidth-34-(float)(sBoxW*.50), pageHeight-60, paint);
	    canvas.drawLine(pageWidth-34-(float)(sBoxW*.25), 650, pageWidth-34-(float)(sBoxW*.25), pageHeight-60, paint);
	    paint.setColor(Color.BLACK);
	    paint.setTextSize(7);
	    paint.setTextAlign(Align.CENTER);
	    canvas.drawText("Your Result", pageWidth-34-(float)(sBoxW*.875), 665, paint );
	    canvas.drawText("(W-L-B)", pageWidth-34-(float)(sBoxW*.875), 675, paint );
	    canvas.drawText("Your", pageWidth-34-(float)(sBoxW*.625), 665, paint );
	    canvas.drawText("Fleet Points", pageWidth-34-(float)(sBoxW*.625), 675, paint );
	    canvas.drawText("Cumulative", pageWidth-34-(float)(sBoxW*.375), 665, paint );
	    canvas.drawText("Fleet Points", pageWidth-34-(float)(sBoxW*.375), 675, paint );
	    canvas.drawText("Opponent's", pageWidth-34-(float)(sBoxW*.125), 660, paint );
	    canvas.drawText("Initials", pageWidth-34-(float)(sBoxW*.125), 670, paint );
	    paint.setTextSize(6);
	    canvas.drawText("(Verify Result)", pageWidth-34-(float)(sBoxW*.125), 680, paint );

	    
	    paint.setColor(Color.BLACK);
	    paint.setTextSize(10);
	    paint.setTextAlign(Align.CENTER);
	    canvas.drawText("Printed by Space Dock Ð www.spacedockapp.org", pageWidth/2, pageHeight-45, paint );

	    paint.setTextSize(10);
	    paint.setColor(Color.BLACK);
		paint.setTextAlign(Align.CENTER);
		canvas.drawText("Type", 34 + (float)(sBoxW*.075), 170, paint);
		canvas.drawText("Card Title", 34 + (float)(sBoxW*.425), 170, paint);
		canvas.drawText("Faction", 34 + (float)(sBoxW*.775), 170, paint);
		canvas.drawText("SP", 34 + (float)(sBoxW*.925), 170, paint);
		
		canvas.drawText("Type", pageWidth-34-sBoxW + (float)(sBoxW*.075), 170, paint);
		canvas.drawText("Card Title", pageWidth-34-sBoxW + (float)(sBoxW*.425), 170, paint);
		canvas.drawText("Faction", pageWidth-34-sBoxW + (float)(sBoxW*.775), 170, paint);
		canvas.drawText("SP", pageWidth-34-sBoxW + (float)(sBoxW*.925), 170, paint);

		canvas.drawText("Type", 34 + (float)(sBoxW*.075), 337, paint);
		canvas.drawText("Card Title", 34 + (float)(sBoxW*.425), 337, paint);
		canvas.drawText("Faction", 34 + (float)(sBoxW*.775), 337, paint);
		canvas.drawText("SP", 34 + (float)(sBoxW*.925), 337, paint);

		canvas.drawText("Type", pageWidth-34-sBoxW + (float)(sBoxW*.075), 337, paint);
		canvas.drawText("Card Title", pageWidth-34-sBoxW + (float)(sBoxW*.425), 337, paint);
		canvas.drawText("Faction", pageWidth-34-sBoxW + (float)(sBoxW*.775), 337, paint);
		canvas.drawText("SP", pageWidth-34-sBoxW + (float)(sBoxW*.925), 337, paint);
		
	    paint.setTextSize(10);
	    paint.setColor(Color.BLACK);
	    paint.setTypeface(Typeface.MONOSPACE);
	    paint.setTextAlign(Align.LEFT);
	    
	    canvas.drawText(this.date, 101, 97, paint);
	    canvas.drawText(this.event, 101, 122, paint);
	    canvas.drawText(this.faction, 101, 147, paint);
	    canvas.drawText(this.name, pageWidth-18-15-160, 97, paint);
	    canvas.drawText(this.email, pageWidth-18-15-160, 122, paint);
	    
	    paint.setTextSize(9);
	    paint.setColor(Color.BLACK);
	    paint.setTypeface(Typeface.MONOSPACE);
	    paint.setTextAlign(Align.LEFT);
	    
    	int othertotal = 0;

	    if ( squad.getEquippedShips().size() >= 1 )
	    {
	    	int shipNo = 1;
	    	for ( EquippedShip ship : squad.getEquippedShips() )
	    	{
	    		if ( shipNo > 4 )
	    		{
	    			othertotal += ship.calculateCost();
	    			continue;
	    		}
	    	    paint.setTextSize(9);

	    		float x = 0,y = 0;
	    		int upgNo = 1;
	    		if ( shipNo == 1 ) { x = 35; y = 170; }
	    		if ( shipNo == 2 ) { x = pageWidth-33-sBoxW; y = 170; }
	    		if ( shipNo == 3 ) { x = 35; y = 338; }
	    		if ( shipNo == 4 ) { x = pageWidth-33-sBoxW; y = 338; }
	    		
	    	    paint.setTextAlign(Align.LEFT);
	    		canvas.drawText("Ship", x, y+(11*upgNo), paint);
	    		canvas.drawText(ship.getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
	    		paint.setTextAlign(Align.CENTER);
	    		canvas.drawText(ship.getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
	    	    paint.setTextAlign(Align.RIGHT);
	    		canvas.drawText(Integer.toString(ship.getBaseCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
	    		upgNo ++;
	    		
	    		if ( ship.getFlagship() != null )
	    		{
		    	    paint.setTextAlign(Align.LEFT);
		    		canvas.drawText("Flag", x, y+(11*upgNo), paint);
		    		canvas.drawText(ship.getFlagship().getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
		    		paint.setTextAlign(Align.CENTER);
		    		canvas.drawText(ship.getFlagship().getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
		    	    paint.setTextAlign(Align.RIGHT);
		    		canvas.drawText(Integer.toString(ship.getFlagship().getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
		    		upgNo ++;
	    		}
	    		
	    		Captain cap = ship.getCaptain();
	    		paint.setTextAlign(Align.LEFT);
	    		canvas.drawText("Captain", x, y+(11*upgNo), paint);
	    		canvas.drawText(cap.getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
	    		paint.setTextAlign(Align.CENTER);
	    		canvas.drawText(cap.getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
	    	    paint.setTextAlign(Align.RIGHT);
	    		canvas.drawText(Integer.toString(cap.getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
	    		upgNo ++;
	    		
	    		if ( ship.getFleetCaptain() != null )
	    		{
		    	    paint.setTextAlign(Align.LEFT);
		    		canvas.drawText("FleetCap", x, y+(11*upgNo), paint);
		    		canvas.drawText(ship.getFleetCaptain().getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
		    		paint.setTextAlign(Align.CENTER);
		    		canvas.drawText(ship.getFleetCaptain().getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
		    	    paint.setTextAlign(Align.RIGHT);
		    		canvas.drawText(Integer.toString(ship.getFleetCaptain().getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
		    		upgNo ++;
	    		}
	    		
	    		
	    		for ( EquippedUpgrade anUpg : ship.getAllUpgradesExceptPlaceholders() )
	    		{
	    			Upgrade theUpg = anUpg.getUpgrade();
	    			if ( anUpg.isCaptain() ) continue;
	    			if ( theUpg.isPlaceholder() ) continue;
	    			
		    		paint.setTextAlign(Align.CENTER);
		    		if ( !theUpg.isTalent() ) canvas.drawText(theUpg.getUpType().substring(0,1), x + (float)(sBoxW*.075), y+(11*upgNo), paint);
		    		if ( theUpg.isTalent() ) canvas.drawText("E".substring(0,1), x + (float)(sBoxW*.075), y+(11*upgNo), paint);
		    		paint.setTextAlign(Align.LEFT);
		    		canvas.drawText(theUpg.getTitle(), x + (float)(sBoxW*.15), y+(11*upgNo), paint);
		    		paint.setTextAlign(Align.CENTER);
		    		canvas.drawText(theUpg.getFaction().toUpperCase().substring(0, 3), x + (float)(sBoxW*.775), y+(11*upgNo), paint);
		    	    paint.setTextAlign(Align.RIGHT);
		    		canvas.drawText(Integer.toString(theUpg.getCost()), x + (float)(sBoxW*.99), y+(11*upgNo), paint);
		    		upgNo ++;
	    		}

	    	    paint.setTextSize(14);
	    		paint.setTextAlign(Align.CENTER);

	    		canvas.drawText(Integer.toString(ship.calculateCost()), (float) (x + (sBoxW*.925)), y+138, paint);
	    		
	    		if ( shipNo == 1 ) canvas.drawText(Integer.toString(ship.calculateCost()), 34+(float)((tW*1)-(tW/2)), 608, paint);
	    		if ( shipNo == 2 ) canvas.drawText(Integer.toString(ship.calculateCost()), 34+(float)((tW*2)-(tW/2)), 608, paint);
	    		if ( shipNo == 3 ) canvas.drawText(Integer.toString(ship.calculateCost()), 34+(float)((tW*3)-(tW/2)), 608, paint);
	    		if ( shipNo == 4 ) canvas.drawText(Integer.toString(ship.calculateCost()), 34+(float)((tW*4)-(tW/2)), 608, paint);

	    		shipNo ++;
	    	}
	    }
	    if ( squad.getResource() != null && !squad.getResource().isPlaceholder() )
	    {
    	    paint.setTextSize(14);
    		paint.setTextAlign(Align.LEFT);

    		canvas.drawText(squad.getResource().getTitle(), 139, 562, paint);
    		paint.setTextAlign(Align.CENTER);
    		if (squad.getResource().getIsFlagship() || squad.getResource().isFleetCaptain() )
    		{
    			canvas.drawText("Inc", pageWidth-51, 562, paint);
    			canvas.drawText("Inc", 34+(float)((tW*5)-(tW/2)), 608, paint);
    		}
    		else
    		{
    			canvas.drawText(Integer.toString(squad.getResource().getCost()), pageWidth-51, 562, paint);
    			canvas.drawText(Integer.toString(squad.getResource().getCost()), 34+(float)((tW*5)-(tW/2)), 608, paint);
    		}
	    }
	    
	    if ( othertotal > 0 ) canvas.drawText(Integer.toString(othertotal), 34+(float)((tW*6)-(tW/2)), 608, paint);
	    
		canvas.drawText(Integer.toString(squad.calculateCost()), 34+(float)((tW*7)-(tW/2)), 608, paint);
	}
	
	private boolean pageInRange(PageRange[] pageRanges, int page)
	{
		for (int i = 0; i<pageRanges.length; i++)
		{
			if ((page >= pageRanges[i].getStart()) && 
                    	                 (page <= pageRanges[i].getEnd()))
				return true;
		}
		return false;
	}
}
