package {
	  import flash.display.Sprite;
	  import flash.events.MouseEvent;
	  import flash.external.ExternalInterface;
	  import flash.system.ApplicationDomain;
	  import flash.utils.getDefinitionByName;
	
	  public class FlashRecorder extends Sprite {
		  
	  private var recorder : Recorder;
	  
	    public function FlashRecorder() {
			
			var logger:Logger = new Logger();
			recorder = new Recorder(logger, loaderInfo.bytes);
			
			var Worker : *;
			if(ApplicationDomain.currentDomain.hasDefinition("flash.system.Worker"))
			{
				Worker = getDefinitionByName("flash.system.Worker");
			}
			
			trace("new worker: "+(Worker?Worker.isSupported+" "+Worker.current.isPrimordial:"undefined"));
			
			if(!Worker || Worker.current.isPrimordial)
			{
			      ExternalInterface.addCallback("debugLog", logger.debugLog);
			      
			      recorder.addExternalInterfaceCallbacks();
				  
//				  graphics.beginFill(0xcccccc);
//				  graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
//				  graphics.endFill();
//				  
//				  stage.addEventListener(MouseEvent.CLICK, function(event : MouseEvent) : void
//				  {
//					  recorder.saveAudioFile();
//				  });
			}
	    }
  }
}