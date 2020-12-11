package control {

import manager.GameEventDispatch;
import manager.GameEvent;
import model.OfflinePowerM;
import manager.ConfigManager;
import manager.ApiManager;
import model.LoginInfoM;
import laya.utils.Handler;
import model.UserInfoM;

public class OfflinePowerC {
    private static var _instance:OfflinePowerC;

    public static function get instance():OfflinePowerC
    {
        return _instance || (_instance = new OfflinePowerC());
    }

    public function OfflinePowerC()
    {
        // GameEventDispatch.instance.on(GameEvent.GoldRateLv, this, setOfflineInfo);
    }

    public function setOfflineInfo():void {

        // 获取离线信息
        var offlineInfo:Object = WxShareC.getStorageSync('offlineInfo');

        var offlinePower:Object = OfflinePowerM.offlinePowerInfo;
        offlinePower = {
            "power":offlinePower.power,
            "power_up_limit":offlinePower.powercountdowm,
        };
        WxShareC.setStorageSync('offlineInfo', offlineInfo);
    }
    //体力更改
    public function setStandbyInfo(offlineInfo):void
    {
        var url:String = '/user_data_change';
        var params:String = 'token=' + LoginInfoM.instance.token + '&power_up_limit=' + offlineInfo.power;

        ApiManager.instance.base_request(url, params, 'POST', setStandbyInfoComplete);
    }

    // 初始化体力值
    public function setStandbyInfoComplete(res):void
    {
        if (res.code == 'success') {
            GameEventDispatch.instance.event(GameEvent.InitOfflinePower);
        }
    }


    // 获取待机收益信息失败
    public function getStandbyInfoError(res):void
    {
        console.log(res);
    }

}
}