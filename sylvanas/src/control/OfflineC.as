package control {
	
	import manager.GameEventDispatch;
	import manager.GameEvent;
	import model.OfflineM;
	import manager.ConfigManager;
	import manager.ApiManager;
	import model.LoginInfoM;
	import laya.utils.Handler;
	import model.UserInfoM;

	public class OfflineC {

		private static var _instance:OfflineC;

        public static function get instance():OfflineC
        {
            return _instance || (_instance = new OfflineC());
        }

		public function OfflineC()
		{
			// GameEventDispatch.instance.on(GameEvent.GoldRateLv, this, setOfflineInfo);
		}

		// 离线收益产生速率变化时需要更新存储离线信息
		public function setOfflineInfo():void
		{

				// 获取离线信息
				var offlineInfo:Object = WxShareC.getStorageSync('offlineInfo');

				// 总倒计时
				var awardInfo:Object = ConfigManager.getConfObject('cfg_award', 1);
				var totalTime:int = awardInfo.time * 3600;

				// 存储离线信息
				var currentDate:Date = new Date();
				var currentTimestamp:int = Math.round(currentDate.getTime() / 1000);
				var totalCountdown:int = 0;
				if (offlineInfo !== '') {
					totalCountdown = (currentTimestamp - offlineInfo.timestamp) >= totalTime ? totalTime : currentTimestamp - offlineInfo.timestamp;
				}
				var offlineGold:int = OfflineM.offlineGold;
				offlineInfo = {
					"countdown": totalCountdown, // 总倒计时
					"timestamp": offlineInfo.timestamp, // 初始时间戳,只在领取待机收益时初始化
					"curTimestamp": currentTimestamp, // 收益率变化时的时间戳
					"gold": offlineGold // 收益率变化时的待机收益
				};
				WxShareC.setStorageSync('offlineInfo', offlineInfo);
		}
	}
}