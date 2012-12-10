package fr.kikko.lab {
	import Shine;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import lib.Shine.CModule;
	
	/**
	 * @author kikko.fr - 2010
	 */
	
	public class ShineMp3Encoder extends EventDispatcher {
		private static var _started : Boolean = false;
		
		public var wavData:ByteArray;
		public var mp3Data : ByteArray;
		
		private var mp3Ptr:int;
		private var mp3LengthPtr:int;
		private var wavPtr:int;
		
		private var wavDuration : int;
		
		private var timer:Timer;
		private var initTime:uint;
		
		public function ShineMp3Encoder() {
			
			if(!_started)
			{
				CModule.startAsync(this);
				_started = true;
			}
		}
		
		public function start(wavData:ByteArray, wavDuration : int) : void {
			this.wavData = wavData;
			this.wavDuration = wavDuration;
			
			initTime = getTimer();
			
			timer = new Timer(1000/30);
			timer.addEventListener(TimerEvent.TIMER, update);
			
			wavPtr = CModule.malloc(wavData.length);
			wavData.position = 0;
			CModule.writeBytes(wavPtr, wavData.length, wavData);
			
			mp3LengthPtr = CModule.malloc(4);
			
			var bitrate : int = 32;
			var mp3Size : int = wavDuration/1000.0*bitrate/8*1024;
			
			mp3Ptr = CModule.malloc(mp3Size);
			Shine.init(wavPtr, wavData.length, mp3Ptr, mp3Size, 1, bitrate);
			
			if(timer) timer.start();
		}
		
		public function shineError(message:String):void {
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, update);
			timer = null;
			
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}
		
		public function saveAs(filename:String=".mp3"):void {
			
			(new FileReference()).save(mp3Data, filename);
		}
		
		private function update(event : TimerEvent) : void {
			
			var percent:int = Shine.update(mp3LengthPtr);
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, percent, 100));
			
			trace("encoding mp3...", percent+"%");
			
			if(percent==100) {
				CModule.free(wavPtr);
				wavPtr = 0;
				
				var mp3Length : int = CModule.read32(mp3LengthPtr);
				CModule.free(mp3LengthPtr);
				mp3LengthPtr = 0;
				
				mp3Data = new ByteArray();
				CModule.readBytes(mp3Ptr, mp3Length, mp3Data);
				CModule.free(mp3Ptr);
				mp3Ptr = 0;
				
				mp3Data.position = 0;
				
				trace("Done in", (getTimer()-initTime) * 0.001 + "s");
				
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, update);
				timer = null;
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function cancel() : void {
			if(wavPtr)
			{
				if(timer)
				{
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, update);
					timer = null;
				}
				
				Shine.cancel();
				CModule.free(wavPtr);
				CModule.free(mp3Ptr);
				CModule.free(mp3LengthPtr);
				
				wavPtr = 0;
				mp3Ptr = 0;
				mp3LengthPtr = 0;
			}
		}
	}
}
