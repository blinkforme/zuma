package model
{
    import conf.cfg_scene;

    import enums.SkillType;

    import fight.FightManager;
    import fight.zuma.ZumaManager;

    import laya.maths.Point;

    import manager.ConfigManager;
    import manager.GameEvent;
    import manager.GameEventDispatch;

    import manager.ApiManager;
    import manager.GameConst;

    import enums.ShowType;

    import manager.UiManager;

    public class FightM
    {
        private static var _instance:FightM;

        private var _allSceneNum:Number = 0;//总关卡数

        private var _eliminateArr:Array;
        private var _hurtNum:Number = 0;

        private var _curPower:Number = 0;
        private var _fullPower:Number = 0;

        private var _oneBallDie:Number = 10;//一个球的能量  没有普攻能量了
        private var _doubleHit:Number = 50;//一次连击的能量

        private var _oneBallScore:Number = 1;
        private var _rewardScore:Number = 0;
        private var _comboTimes:Number = 0;
        private var _curScore:Number = 0;
        private var _sceneScore:Number = 0;

        private var _limitTime:Number = 0;//秒
        private var _reviveCount:Number;//复活次数

        private var _executeSkillId:Number = SkillType.NOSKILL;
        private var _skillNumArr:Object = {32: 0, 33: 0};

        public function FightM()
        {
            _eliminateArr = [];
        }

        public static function get instance():FightM
        {
            return _instance || (_instance = new FightM());
        }


        //本关卡倒计时总时间
        public function setSceneLimitTime(sceneId:Number):Number
        {
            _limitTime = cfg_scene.instance(sceneId + "").limit_time;
        }

        //倒计时
        public function countDown():void
        {
            _limitTime -= 1;
            if (_limitTime < 0)
            {
                _limitTime = 0;
            }
        }

        //显示此刻的还剩余时间
        public function getShowLimitTime():String
        {
            var hour:Number;
            var minute:Number;
            var second:Number;
            var hourStr:String;
            var minuteStr:String;
            var secondStr:String;
            var str:String = "";
            second = _limitTime % 60;
            minute = (_limitTime - second) / 60;
            if (minute > 60)
            {
                minute = minute % 60;
                hour = Math.floor(minute / 60);
                secondStr = "0" + second;
                minuteStr = "0" + minute;
                hourStr = "0" + hour;
                str = hourStr.slice(hourStr.length - 2) + ":" + minuteStr.slice(minuteStr.length - 2) + ":" + secondStr.slice(secondStr.length - 2)
            } else
            {
                secondStr = "0" + second;
                minuteStr = "0" + minute;
                str = minuteStr.slice(minuteStr.length - 2) + ":" + secondStr.slice(secondStr.length - 2)
            }
            return str;
        }

        //存贮每次的祖玛的消除状态
        //var arg:Object = {
        //            num: ballNums,  //本次消除的球数
        //            times: hitTimes  //本次连击次数
        //        };
        public function setHitAction(arg:Object):void
        {
            _eliminateArr.push(arg);
        }

        //每次消除得分加到总分数上
        public function allScoreAddHitScore(arg:Object):void
        {
            if (arg.times > 1)
            {
                _rewardScore += arg.num * _oneBallScore;
                _curScore = arg.num * _oneBallScore + _rewardScore;
                FightManager.instance.showBallPowerChange(new Point(Laya.stage.width / 2, Laya.stage.height / 2), _rewardScore);
                //                GameEventDispatch.instance.event(GameEvent.ComboAniShow, {times: arg.times, reward: _rewardScore});
            } else
            {
                _rewardScore = arg.num * _oneBallScore;
                _curScore = arg.num * _oneBallScore;
            }
            _sceneScore += _curScore;
            ZumaManager.instance.playerVectory();
            GameEventDispatch.instance.event(GameEvent.UpdatePowerData);
        }

        //是否能执行大招
        public function isCanShowBigSkill():Boolean
        {
            var fullPwer:Number = bigSkillNeedPower();
            var arg:Object = _eliminateArr[0];
            var nextPower:Number = _curPower + getPowerValueOfBall(arg.num, arg.times);
            if (nextPower >= fullPwer)
            {
                return true;
            }
            return false;
        }

        //执行普通技能
        public function carryOutNomallSkill():void
        {
            var arg:Object = _eliminateArr[0];
            _hurtNum = arg.num * nomalAtk();
            _curPower += getPowerValueOfBall(arg.num, arg.times);
            _eliminateArr.splice(0, 1);
        }

        //获取本次消除产生的能量
        public function getPowerValueOfBall(num:Number, times:Number):Number
        {
            return (times - 1) * _doubleHit + _doubleHit
        }

        //执行大招技能
        public function carryOutBigSkill():void
        {
            var arg:Object = _eliminateArr[0];
            _hurtNum = bigSkillAtk();
            _curPower += getPowerValueOfBall(arg.num, arg.times);
            _eliminateArr.splice(0, 1);
            _curPower -= bigSkillNeedPower();
        }

        //产生的能量百分比
        public function get powerPercent():Number
        {
            if (_curPower < 0)
            {
                _curPower = 0;
            }
            var value:Number = _curPower / bigSkillNeedPower();
            if (value > 1)
            {
                value = 1;
            }
            return value;
        }

        //显示能量比字符串
        public function get showPowerStr():String
        {
            var value:String;
            if (_curPower < 0)
            {
                _curPower = 0;
            }
            if (_curPower > bigSkillNeedPower())
            {
                value = bigSkillNeedPower() + " /" + bigSkillNeedPower();
            } else
            {
                value = _curPower + " /" + bigSkillNeedPower();
            }
            return value;
        }

        //重置战斗变量
        public function setFightModelReset():void
        {
            _eliminateArr = [];//每次消除的数组
            _hurtNum = 0;//每次的伤害
            _curPower = 0;//当前积累的能量
            _fullPower = 0;//总能量
            _sceneScore = 0;
            _curScore = 0;
        }

        //0:不限时,1:限时
        public function get isTimeLimit():Number
        {
            return ConfigManager.getConfValue("cfg_scene", LoginM.instance.sceneId, "is_time_limit")[1] as Number;
        }

        //普通伤害
        public function nomalAtk():Number
        {
            return ConfigManager.getConfValue("cfg_property_level", UserInfoM.attackLv, "common_atk")[1] as Number;
        }

        //大招伤害
        public function bigSkillAtk():Number
        {
            return ConfigManager.getConfValue("cfg_property_level", UserInfoM.skillLv, "skill_atk")[1] as Number;
        }

        //执行大招需要的能量
        public function bigSkillNeedPower():Number
        {
            return ConfigManager.getConfValue("cfg_global", 1, "upper_energy") as Number;
        }

        public function get needScore():Number
        {
            return ConfigManager.getConfValue("cfg_scene", LoginM.instance.sceneId, "limit_score") as Number;
        }

        //当前等级一分对应的金币获取量
        public function curLevelGetGold():Number
        {
            return 1
        }

        public function get curPower():Number
        {
            return _curPower;
        }

        public function set curPower(value:Number):void
        {
            _curPower = value;
        }

        public function get fullPower():Number
        {
            return _fullPower;
        }

        public function set fullPower(value:Number):void
        {
            _fullPower = value;
        }

        public function get eliminateArr():Array
        {
            return _eliminateArr;
        }

        public function get hurtNum():Number
        {
            return _hurtNum;
        }

        public function get limitTime():Number
        {
            return _limitTime;
        }

        public function get allSceneNum():Number
        {
            return _allSceneNum;
        }

        public function set allSceneNum(value:Number):void
        {
            _allSceneNum = value;
        }

        public function get sceneScore():Number
        {
            return _sceneScore;
        }


        //获取复活次数
        public function getReviveCount():void
        {
            var sceneId = LoginM.instance.sceneId
            var score = _sceneScore;
            var status = AccountM.instance.acoountType == GameConst.Account_Type_Vectory ? 1 : 0;
            var url:String = '/mission_finish';
            var params:String = 'token=' + LoginInfoM.instance.token + '&mission_id=' + sceneId +
                    '&score=' + score + '&status=' + status;

            ApiManager.instance.base_request(url, params, 'POST', getReviveCountComplete);
        }

        public function getReviveCountComplete(res):void
        {
            if (res.code == 'success')
            {
                FightM.instance.reviveCount = res.data.can_revival;
                UiManager.instance.loadView("Account", null, ShowType.SMALL_TO_BIG);
            }
        }

        public function get reviveCount():Number
        {
            return _reviveCount;
        }

        public function set reviveCount(value:Number):void
        {
            _reviveCount = value;
        }

        public function get skillNumArr():Object
        {
            return _skillNumArr;
        }

        public function set skillNumArr(value:Object):void
        {
            _skillNumArr = value;
        }

        public function get executeSkillId():Number
        {
            return _executeSkillId;
        }

        public function set executeSkillId(value:Number):void
        {
            _executeSkillId = value;
        }
    }
}
