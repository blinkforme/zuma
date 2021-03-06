/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package {
	import laya.utils.ClassUtils;
	import laya.ui.View;
	import laya.webgl.WebGL;
	import laya.ui.WXOpenDataViewer;
	import laya.display.Text;
	/**
	 * 游戏初始化配置
	 */
	public class GameConfig {
		public static var width:int = 720;
		public static var height:int = 1280;
		public static var scaleMode:String = "fixedheight";
		public static var screenMode:String = "none";
		public static var alignV:String = "middle";
		public static var alignH:String = "center";
		public static var startScene:* = "sylvanas/FriendsRanking.scene";
		public static var sceneRoot:String = "";
		public static var debug:Boolean = false;
		public static var stat:Boolean = false;
		public static var physicsDebug:Boolean = false;
		public static var exportSceneToJson:Boolean = true;
		
		public static function init():void {
			//注册Script或者Runtime引用
			var reg:Function = ClassUtils.regClass;
			reg("laya.ui.WXOpenDataViewer",WXOpenDataViewer);
			reg("laya.display.Text",Text);
		}
		GameConfig.init();
	}
}