package control
{
    import laya.utils.Handler;

    import manager.ApiManager;
    import manager.GameEvent;
    import manager.GameEventDispatch;

    import model.LoginInfoM;
    import model.OfflinePowerM;
    import model.UserInfoM;


    public class UserInfoC
    {

        private static var _instance:UserInfoC;

        public static function get instance():UserInfoC
        {
            return _instance || (_instance = new UserInfoC());
        }

        public function UserInfoC()
        {
            GameEventDispatch.instance.on(GameEvent.NatureSave, this, setNature);
            GameEventDispatch.instance.on(GameEvent.GoldSave, this, setGold);
        }


        public function setNature(data:*):void
        {
            trace("DATA", data)
            var url:String = '/user_upgrade';
            var params:String = 'token=' + LoginInfoM.instance.token + '&attackLv=' + data.attackLv + '&skillLv=' + data.skillLv + '&goldRateLv=' + data.goldRateLv + '&killOutputLv=' + data.killOutputLv;

            ApiManager.instance.base_request(url, params, 'POST', setNatureReturn);
        }

        public function setNatureReturn(res):void
        {
            if (res.code == 'success')
            {
                UserInfoM.attackLv = res.data.attackLv;
                UserInfoM.skillLv = res.data.skillLv;
                UserInfoM.goldRateLv = res.data.goldRateLv;
                UserInfoM.killOutputLv = res.data.killOutputLv;
                GameEventDispatch.instance.event(GameEvent.NatureChange);
            } else
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "升级失败")
            }
        }

        public function setGold(data:int):void
        {
            var url:String = '/gold_change';
            var params:String = 'token=' + LoginInfoM.instance.token + '&change_value=' + data;

            ApiManager.instance.base_request(url, params, 'POST', setGoldReturn);
        }

        public function setGoldReturn(res):void
        {
            if (res.code == 'success')
            {
                UserInfoM.gold = res.data.gold;
                GameEventDispatch.instance.event(GameEvent.GoldChange)
            }
        }

        public function getUserInfo():void
        {
            var url:String = '/user_data?token=' + LoginInfoM.instance.token;
            var params:String = 'token=' + LoginInfoM.instance.token;

            ApiManager.instance.basehttp(url, params, 'GET', Handler.create(this, getUserInfoRe), Handler.create(this, getUserInfoError));
        }

        public function getUserInfoRe(res):void
        {
            if (res.code == 'success')
            {
                if (res && res.data.attackLv)
                {
                    UserInfoM.attackLv = res.data.attackLv;
                }
                if (res && res.data.skillLv)
                {
                    UserInfoM.skillLv = res.data.skillLv;
                }
                if (res && res.data.goldRateLv)
                {
                    UserInfoM.goldRateLv = res.data.goldRateLv;
                }
                if (res && res.data.killOutputLv)
                {
                    UserInfoM.killOutputLv = res.data.killOutputLv;
                }
                if (res && res.data.gold)
                {
                    UserInfoM.gold = res.data.gold;
                }
                if (res && res.data.power)
                {
                    UserInfoM.power = res.data.power;
                }
                if (res && res.data.power_has_go_time != null)
                {
                    UserInfoM.power_has_go_time = res.data.power_has_go_time;
                }
                if (res)
                {
                    UserInfoM.useSkinId = res.data.use_skin_id;
                    UserInfoM.haveSkinsId = res.data.has_skin_ids;
                }
                GameEventDispatch.instance.event(GameEvent.NatureChange);
                GameEventDispatch.instance.event(GameEvent.GoldChange);
                GameEventDispatch.instance.event(GameEvent.LoopPower);
                GameEventDispatch.instance.event(GameEvent.InitShop);
                GameEventDispatch.instance.event(GameEvent.InitMosterSkin);
            }
        }

        public function getUserPowerInfo():void
        {
            var url:String = '/global_data?token=' + LoginInfoM.instance.token;
            var params:String = 'token=' + LoginInfoM.instance.token;

            ApiManager.instance.basehttp(url, params, 'GET', Handler.create(this, getUserPowerInfoRes), Handler.create(this, getUserInfoError));
        }

        public function getUserPowerInfoRes(res):void
        {
            if (res.code == 'success')
            {
                if (res && res.data.power_up_limit != null)
                {
                    UserInfoM.power_up_limit = res.data.power_up_limit
                }
                if (res && res.data.power_up_interval_time != null)
                {
                    UserInfoM.power_up_limit_time = res.data.power_up_interval_time
                }
            }
        }

        public function getUserInfoError():void
        {

        }

    }
}