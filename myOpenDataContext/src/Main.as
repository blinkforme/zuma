package {
	import laya.net.ResourceVersion;
	import laya.net.URL;
	import laya.utils.Handler;
	import laya.utils.Stat;
	import laya.utils.Utils;
	import laya.utils.Browser;
	import view.FriendsRanking;
import view.friendsRanking.FriendsRanking;

public class Main {
		public function Main() {
			//设置子域
			Laya.isWXOpenDataContext = true;
			Laya.isWXPosMsg = true;
			//根据IDE设置初始化引擎		
			Laya.init(GameConfig.width, GameConfig.height,false);
			//根据IDE设置初始化引擎		
			Laya.stage.scaleMode = GameConfig.scaleMode;
			Laya.stage.screenMode = GameConfig.screenMode;
			Laya.stage.alignV = GameConfig.alignV;
			Laya.stage.alignH = GameConfig.alignH;
			// 关于透传接口，请参考: https://ldc2.layabox.com/doc/?nav=zh-ts-5-0-7
			if(Browser.onMiniGame)//需要从主域透传
				Browser.window.wx.onMessage(function(data:*):void{
					//透传结构
					if(data.url == "res/atlas/ui/friendsRanking.atlas"){
						Laya.loader.load("res/atlas/ui/friendsRanking.atlas",Handler.create(this,onComplete));
					}
				}.bind(this));
			else
				Laya.loader.load("res/atlas/ui/friendsRanking.atlas",Handler.create(this,onComplete));
		}
		
		private function onComplete():void {
			//加载场景
			var ranking:FriendsRanking = new FriendsRanking();
			ranking.init();
		}
	}
}