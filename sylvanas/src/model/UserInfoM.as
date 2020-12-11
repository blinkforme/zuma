package model
{

    import conf.cfg_global;

    import control.WxC;

    import laya.media.SoundManager;

    import manager.ConfigManager;

    import manager.GameEvent;
    import manager.GameEventDispatch;
    import control.WxShareC;
    import manager.ApiManager;

    public class UserInfoM
    {

        private static var _instance:UserInfoM;
        private var _name:String;
        private var _avatar:String;
        public static var _gold:Number = 0; //玩家金币
        public static var attackLv:Number = 1;//普通攻击等级
        public static var skillLv:Number = 1;//大招等级
        public static var ballSpeedLv:Number = 1;//珠子速度等级
        public static var goldRateLv:Number = 1;//产币速度等级
        public static var upperEnergyLv:Number = 1;//能量上限等级
        public static var killOutputLv:Number = 1;//杀怪产币等级

        public static var param_arr:Array = [];
        public static var _user_info:Object;

        public static var gold:int = 0; // 总金币
        public static var power:int = 0;//体力值
        public static var power_has_go_time:int = 0;//体力储蓄时间
        public static var power_up_limit:int = 0;//体力上限
        public static var power_up_limit_time:int = 0;//体力增加间隔时间

        public static var useSkinId:int = 0;//正在使用的皮肤ID
        public static var haveSkinsId:Array = [];//已经拥有的皮肤ID

        public function UserInfoM()
        {


        }

        private function setInfo():void
        {
            _user_info = {
                "attackLv": attackLv,   //普通攻击等级
                "skillLv": skillLv,   //大招等级
                "goldRateLv": goldRateLv,  //离线产币速率
                "killOutputLv":killOutputLv,  //杀怪产币系数
                "power":power,//体力值
                "power_has_go_time":power_has_go_time,//累积时间
                "power_up_limit_time":power_up_limit_time,//
            };
        }

        public function upGrade(type:Number, expend:Number):void
        {
                if ((gold-expend) > 0)
                {
                    if (type == 0)
                    {
                        attackLv = attackLv + 1;
                    }
                    if (type == 1)
                    {
                        skillLv = skillLv + 1;
                    }
                    if (type == 2)
                    {
                        goldRateLv = goldRateLv + 1;
                        // GameEventDispatch.instance.event(GameEvent.GoldRateLv);
                    }
                    if (type == 3)
                    {
                        killOutputLv = killOutputLv + 1;
                    }
                    gold = gold-expend;
                    setInfo();
                    param_arr = [UserInfoM._user_info];
                    SoundManager.playSound(cfg_global.instance(1).edu_music,1)
                    GameEventDispatch.instance.event(GameEvent.MsgTipContent,"升级成功");
                    GameEventDispatch.instance.event(GameEvent.NatureSave,param_arr);
                    GameEventDispatch.instance.event(GameEvent.GoldSave, 0 - expend);
                }else
                {
                    GameEventDispatch.instance.event(GameEvent.MsgTipContent,"金币不足,升级失败")
                    SoundManager.playSound(cfg_global.instance(1).fail_music,1)
                }
            }




        public function setGold(value:Number):void
        {
            _gold = _gold + value;
            setInfo();
            GameEventDispatch.instance.event(GameEvent.GoldChange, ["userInfo", UserInfoM._user_info]); 
        }

        // 领取金币
		public function receiveGold(gold):void
		{
			var url:String = '/gold_change';
			var params:String = 'token=' + LoginInfoM.instance.token + '&change_value=' + gold + '&event_id=1';

			ApiManager.instance.base_request(url, params, 'POST', receiveGoldComplete);
		}

		// 成功领取金币
		public function receiveGoldComplete(res):void
		{
			if (res.code == 'success') {
				UserInfoM.gold = res.data.gold;
				GameEventDispatch.instance.event(GameEvent.ResetOfflineInfo);
			}
		}

        public function changePower(power):void
        {
            var url:String = '/user_data_change';
            var params:String = 'token=' + LoginInfoM.instance.token + '&change_value=' + power + '&change_type=' + "power";

            ApiManager.instance.base_request(url, params, 'POST', changePowerComplete);
        }

        public function changePowerComplete(res):void
        {
            if (res.code == 'success') {
                UserInfoM.power = res.data.value;
                GameEventDispatch.instance.event(GameEvent.ResetPower);
                GameEventDispatch.instance.event(GameEvent.InitOfflinePower);
            }
        }

        public static function get instance():UserInfoM
        {
            return _instance || (_instance = new UserInfoM());
        }

        public function get name():String
        {
            return _name;
        }

        public function set name(value:String):void
        {
            _name = value;
        }

        public function get avatar():String
        {
            return _avatar;
        }

        public function set avatar(value:String):void
        {
            _avatar = value;
        }


    }
}

