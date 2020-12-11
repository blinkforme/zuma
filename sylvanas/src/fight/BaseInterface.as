package fight
{
	public interface BaseInterface
	{
		function update(delta:Number):void;
		function isValid():Boolean;
		function destroy():void;
	}
}