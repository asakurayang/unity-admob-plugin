package net.mikinya.admob;

import java.util.ArrayList;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;

import com.google.ads.Ad;
import com.google.ads.AdListener;
import com.google.ads.AdRequest;
import com.google.ads.AdSize;
import com.google.ads.AdView;
import com.unity3d.player.UnityPlayer;

public class AdViewController implements AdListener{
//	static private int BANNER_REFRESH_RATE = 1000 * 60 * 5;
	private Handler handler;
	private Activity activity;
	private AdView adView;
//	private Timer timer;
	private ArrayList<String> testDevices;
	public String adMobID;
	public int position;
	
	class AdPosition{
		final static int TOP = 0;
		final static int BOTTOM = 1;
		final static int TOP_LEFT = 2;
		final static int TOP_RIGHT = 3;
		final static int BOTTOM_LEFT = 4;
		final static int BOTTOM_RIGHT = 5;
	}
	
	public AdViewController(){
		activity = UnityPlayer.currentActivity;
		handler = new Handler(Looper.getMainLooper());
		testDevices = new ArrayList<String>();
	}
	
	public void installAdMobForAndroid(String adMobID, int position){
		this.adMobID = adMobID;
		this.position = position;

		handler.post(new Runnable(){
	        @Override
	        public void run(){
	        	addAdView();
	        	Log.d("AdViewController","installAd");
	        }
	    });
	}
	
	public void addTestDevice(String testDeviceID){
		testDevices.add(testDeviceID);
	}
	
	private void addAdView(){
		LinearLayout layout = new LinearLayout(activity);
		switch(this.position){
		case AdPosition.TOP:
			layout.setGravity(Gravity.CENTER_HORIZONTAL|Gravity.TOP);
			break;
		case AdPosition.BOTTOM:
			layout.setGravity(Gravity.CENTER_HORIZONTAL|Gravity.BOTTOM);
			break;
		case AdPosition.TOP_LEFT:
			layout.setGravity(Gravity.TOP|Gravity.LEFT);
			break;
		case AdPosition.TOP_RIGHT:
			layout.setGravity(Gravity.TOP|Gravity.RIGHT);
			break;
		case AdPosition.BOTTOM_LEFT:
			layout.setGravity(Gravity.BOTTOM|Gravity.LEFT);
			break;
		case AdPosition.BOTTOM_RIGHT:
			layout.setGravity(Gravity.BOTTOM|Gravity.RIGHT);
			break;
		}
		activity.addContentView(layout, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
	    adView = new AdView(activity, AdSize.SMART_BANNER, adMobID);
	    adView.setAdListener(this);
	    layout.addView(adView); 
	}
	
	public void hideAd(){
		handler.post(new Runnable(){
	        @Override
	        public void run(){
	        	adView.setVisibility(View.GONE);
	        }
		});
	}
	
	public void showAd(){
		handler.post(new Runnable(){
	        @Override
	        public void run(){
	        	adView.setVisibility(View.VISIBLE);
	        }
		});
	}
	
	public void refreshAd(){
		cancelRefreshTimer();
		handler.post(new Runnable(){
			@Override
			public void run(){
				AdRequest request = new AdRequest();
				
				request.addTestDevice(AdRequest.TEST_EMULATOR); 
				for(String device_id : testDevices) {
					request.addTestDevice(device_id);
				}
				
				adView.loadAd(request);
				Log.d("AdViewController","refreshAd");
			}
		});
    }
	
	public void cancelRefreshTimer(){
//		if(timer != null){
//			timer.cancel();
//			timer = null;
//		}
	}
	
	// Admob Event Listener
    public void onDismissScreen(Ad ad){}
    
    public void onFailedToReceiveAd(Ad ad, AdRequest.ErrorCode error) {
//        if(timer != null) return;
//        
//    	timer = new Timer(true);
//        TimerTask mTask = new TimerTask() {
//            @Override
//            public void run() {
//            	refreshAd();
//            }                    
//        };
//        
//        timer.schedule(mTask, BANNER_REFRESH_RATE);
    }
	public void onLeaveApplication(Ad ad){}
	
	public void onPresentScreen(Ad ad){}
	
	public void onReceiveAd(Ad ad){}
}
