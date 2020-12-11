package fight.zuma
{
    import fight.*;

    import control.WxShareC;

    import enums.GunMoveType;
    import enums.LevelPassType;
    import enums.SoundType;

    import fight.state.chain.BackState;
    import fight.state.chain.FreezeState;

    import laya.display.Sprite;
    import laya.events.Event;
    import laya.maths.Point;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.GameSoundManager;

    import model.AccountM;
    import model.FightM;
    import model.LoginM;
    import model.SceneM;

    public class ZumaManager
    {
        public static var _instance:ZumaManager;

        private var _zuma_layers:Array;//祖玛层
        private var _zumaRoot:Sprite;//祖玛根节点


        private var _fireGun:FireGun;
        private var _fireBall:FireBall;//要发射的球
        private var _prepareBall:FireBall;//第二颗预备球
        private var _misTouchState:Boolean = false;

        private var _ballIsJump:Boolean = false;

        private var _gameState:Number = GameConst.StopZuma;

        public function ZumaManager()
        {

        }

        public function init(root:Sprite, layer:Array)
        {
            _zumaRoot = root;
            _zuma_layers = layer;
        }

        public static function dispose():void
        {
            _instance = null
        }

        public static function get instance():ZumaManager
        {
            return _instance || (_instance = new ZumaManager());
        }


        public function gameStart():void
        {
            trace("祖玛游戏开始");
            Laya.stage.hitTestPrior = false;
            ZumaMap._snakeSegment = [];
            _zumaRoot.visible = true;
            _startPoint = new Point(0, 0);
            _endPoint = new Point(0, 0);
            ZumaMap.instance.initMap(_zuma_layers[GameConst.bg_layer_index], _zuma_layers[GameConst.ball_layer_index], LoginM.instance.sceneId);
            if (!_fireGun)
            {
                _fireGun = FireGun.create(_zuma_layers[GameConst.firegun_layer_index], _zuma_layers[GameConst.ball_layer_index]);
            }
            _fireGun.updateBornPos();
            _gameState = GameConst.StartZuma;
            refreshNewFireBall();
            GameSoundManager.playExcelMusic(SoundType.ROLLING);
            Laya.stage.on(Event.MOUSE_DOWN, this, onFireGunMouseDown);
            Laya.stage.on(Event.MOUSE_MOVE, this, onFireGunMouseMove);
            Laya.stage.on(Event.MOUSE_UP, this, onFireGunLaunch);
            if (ZumaMap.instance.gunMoveType == GunMoveType.JUMP)
            {
                ZumaMap.instance.onePedestal.on(Event.CLICK, this, onOnePedestal);
                ZumaMap.instance.twoPedestal.on(Event.CLICK, this, onTwoPedestal);
            }
            GameEventDispatch.instance.once(GameEvent.BallIntoHole, this, onBallIntoHole);
            if (FightM.instance.isTimeLimit == LevelPassType.TIMELIMIT)
            {
                GameEventDispatch.instance.once(GameEvent.GameTimeOut, this, onGameTimeOut);
            }
            GameEventDispatch.instance.on(GameEvent.EliminateComplete, this, eliminateHandle);
        }

        public function onGoOnGameOneTimes():void
        {
            Laya.stage.on(Event.MOUSE_DOWN, this, onFireGunMouseDown);
            Laya.stage.on(Event.MOUSE_MOVE, this, onFireGunMouseMove);
            Laya.stage.on(Event.MOUSE_UP, this, onFireGunLaunch);
            if (ZumaMap.instance.gunMoveType == GunMoveType.JUMP)
            {
                ZumaMap.instance.onePedestal.on(Event.CLICK, this, onOnePedestal);
                ZumaMap.instance.twoPedestal.on(Event.CLICK, this, onTwoPedestal);
            }
            GameEventDispatch.instance.once(GameEvent.BallIntoHole, this, onBallIntoHole);
            if (FightM.instance.isTimeLimit == LevelPassType.TIMELIMIT)
            {
                GameEventDispatch.instance.once(GameEvent.GameTimeOut, this, onGameTimeOut);
            }
            GameEventDispatch.instance.on(GameEvent.EliminateComplete, this, eliminateHandle);
        }

        private function onOnePedestal():void
        {
            _fireBall.jumpOtherPoint(true, false);
            _prepareBall.jumpOtherPoint(true, true);
            _fireGun.jumpOtherPoint(true);
        }

        private function onTwoPedestal():void
        {
            _fireBall.jumpOtherPoint(false, false);
            _prepareBall.jumpOtherPoint(false, true);
            _fireGun.jumpOtherPoint(false);
        }

        public function offAllClick():void
        {
            if (ZumaMap.instance.gunMoveType == GunMoveType.JUMP)
            {
                ZumaMap.instance.onePedestal.on(Event.CLICK, this, onOnePedestal);
                ZumaMap.instance.twoPedestal.on(Event.CLICK, this, onTwoPedestal);
            }
            GameEventDispatch.instance.off(GameEvent.EliminateComplete, this, eliminateHandle);
            GameEventDispatch.instance.off(GameEvent.BallIntoHole, this, onBallIntoHole);
            GameEventDispatch.instance.off(GameEvent.GameTimeOut, this, onGameTimeOut);
            Laya.stage.off(Event.MOUSE_DOWN, this, onFireGunMouseDown);
            Laya.stage.off(Event.MOUSE_MOVE, this, onFireGunMouseMove);
            Laya.stage.off(Event.MOUSE_UP, this, onFireGunLaunch);
            accountDataAndSynMsg();
        }

        public function gameStop():void
        {
            var oneChain:FightChain;
            for (var i:int = 0; i < ZumaMap._fightChainArr.length; i++)
            {
                oneChain = ZumaMap._fightChainArr[i];
                oneChain.destory();
            }
            ZumaMap.instance.gameStop();
        }


        private function accountDataAndSynMsg():void
        {
            //本次get数据
            //                var sceneInfo:Object = {
            //                    "sceneId": curSceneId, // 当前关卡ID
            //                    "sceneList": [
            //                        {
            //                            "sceneId": LoginM.instance.sceneId, // 关卡ID
            //                            "pass": isVectory, // 0：未解锁，1：通关，2：解锁未通关
            //                            "star": startNum // 星星数0/1/2/3
            //                        }
            //                    ]
            //                }
            var isVectory:Number = 2;
            var startNum = 0;
            var sceneInfo:Object = SceneM.sceneInfo;
            var curSceneId:Number = LoginM.instance.sceneId;
            var curInfo:Object = sceneInfo.sceneList[curSceneId - 1];
            var nextInfo:Object = sceneInfo.sceneList[curSceneId];
            if (FightM.instance.sceneScore >= FightM.instance.needScore)
            {

                isVectory = 1;
                startNum = 3;
                if (nextInfo && nextInfo.pass == 0)
                {
                    curSceneId++;
                    nextInfo.pass = 2;
                }
            }
            if (curInfo.star < startNum)
            {
                curInfo.pass = isVectory;
                curInfo.star = startNum;
            }
            if (LoginM.instance.sceneId >= sceneInfo.sceneId)
            {
                sceneInfo.sceneId = curSceneId;
                // 通关最新关卡后在微信环境下保存用户数据到微信服务器
                if (curInfo.pass == 1)
                {
                    if (WxShareC.isInMiniGame())
                    {
                        setRankData(sceneInfo)
                    }
                }
            }
            //             WxShareC.setStorageSync("sceneInfo", sceneInfo);
            SceneM.instance.setSceneInfo(JSON.stringify(sceneInfo));
        }

        public function setRankData(data:Object):void
        {
            var sceneId:int = data.sceneId - 1; // 当前最新通关关卡
            var currentDate:Date = new Date();
            var currentTimestamp:int = Math.round(currentDate.getTime() / 1000);
            var value:Object = {
                "wxgame": {
                    "score": sceneId,
                    "update_time": currentTimestamp
                },
                "sceneId": sceneId
            }

            var KVDataList:Array = [{
                key: 'score',
                value: JSON.stringify(value)
            }];

            WxShareC.setUserData(KVDataList);
        }


        private function onBallIntoHole():void
        {
            playerFail();
        }

        public function playerVectory():void
        {
            if (FightM.instance.sceneScore >= FightM.instance.needScore)
            {
                AccountM.instance.acoountType = GameConst.Account_Type_Vectory;
                //玩家胜利
                GameEventDispatch.instance.event(GameEvent.FightStop);
            }
        }

        public function playerFail():void
        {
            AccountM.instance.acoountType = GameConst.Account_Type_Fail;
            //玩家失败
            GameEventDispatch.instance.event(GameEvent.FightStop);
        }

        private function eliminateHandle(ballNums:Number, hitTimes:Number):void
        {
            var obj:Object = {
                num: ballNums,
                times: hitTimes
            };
            FightM.instance.allScoreAddHitScore(obj);
            //            FightM.instance.setHitAction(obj);
        }

        private function onGameTimeOut():void
        {
            if (FightM.instance.sceneScore >= FightM.instance.needScore)
            {
                AccountM.instance.acoountType = GameConst.Account_Type_Vectory;
                //玩家胜利
                GameEventDispatch.instance.event(GameEvent.FightStop);
            } else
            {
                playerFail();
            }
        }

        //刷新一个新球
        private function refreshNewFireBall():void
        {
            if (!_fireBall)
            {
                _fireBall = FireBall.create(_zuma_layers[GameConst.ball_layer_index], gameStrategy());
            }
            if (!_prepareBall)
            {
                _prepareBall = FireBall.create(_zuma_layers[GameConst.firegun_layer_index], gameStrategy());
            }
            _fireBall.setAniSprite(gameStrategy(), false);
            _fireBall.setActive(true);
            _fireBall.initFireBallPos(false)
            _prepareBall.setAniSprite(gameStrategy(), true)
            _prepareBall.setActive(true);
            _prepareBall.initFireBallPos(true)
            _prepareBall.setScale(0.3);

        }

        //检测碰撞
        private function checkFireBallCross():void
        {
            var fireBallList:Array = _fireGun.getActiveFireList();
            for (var i:Number = 0; i < fireBallList.length; i++)
            {

                var fire:FireBall = fireBallList[i];
                for (var j:int = 0; j < ZumaMap._fightChainArr.length; j++)
                {
                    var chain:FightChain = ZumaMap._fightChainArr[j];
                    var ball:Ball = chain.collision(fire.getDesignPoint())

                    if (ball)
                    {
                        //                        chain.testPrintAllBall()
                        var insert:Ball = createActiveBall(fire.type);

                        insert.moveTo(fire.getDesignPoint())

                        chain.hit(insert, ball);
                        fireBallList.splice(i--, 1);
                        fire.destroy()
                        break
                    }
                }
            }
        }

        public function useBackSkill():void
        {
            for (var i:int = 0; i < ZumaMap._fightChainArr.length; i++)
            {
                var chain:FightChain = ZumaMap._fightChainArr[i];
                chain.fsm.changeState(BackState.instance)
            }
        }

        public function useFreezeSkill():void
        {
            for (var i:int = 0; i < ZumaMap._fightChainArr.length; i++)
            {
                var chain:FightChain = ZumaMap._fightChainArr[i];
                chain.fsm.changeState(FreezeState.instance)
            }
        }


        public function update(delta:Number):void
        {
            checkFireBallCross();
            for (var i:int = 0; i < ZumaMap._fightChainArr.length; i++)
            {
                var chain:FightChain = ZumaMap._fightChainArr[i];
                chain.fsm.update()
            }
            _fireGun.update(GameConst.fixed_update_time);
            ZumaMap.instance.update(delta);
        }


        public function createActiveBall(balltype:Number = null):Ball
        {
            var ball:Ball;
            if (balltype && balltype > 0)
            {
                ball = Ball.create(_zuma_layers[GameConst.ball_layer_index], balltype);

            } else
            {
                var type = gameStrategy()
                ball = Ball.create(_zuma_layers[GameConst.ball_layer_index], type);
            }
            return ball;
        }


        private static var _type:Number = -1;
        private static var _typeNumber:Number = 0;

        // 游戏策略
        public static function gameStrategy():Number
        {
            if (_typeNumber <= 0)
            {
                _typeNumber = Math.floor(Math.random() + 1);
                _type = Math.ceil(Math.random() * ZumaMap.instance.ballType);
                //                _type = Math.ceil(Math.random() * 2);
            }

            _typeNumber--;
            return _type;
        }


        private var _startPoint:Point;
        private var _endPoint:Point;
        private var _len:Number = 0;

        private function setPoint(setP:Point, setedP:Point):void
        {
            setedP.x = setP.x;
            setedP.y = setP.y;
        }

        private function onFireGunMouseDown(e:Event):void
        {
            if (e.target.name == "Pedestal")
            {
                return
            }
            e.stopPropagation();
            if (_ballIsJump == false && _fireBall.getActive() == true && _misTouchState == false)
            {
                _misTouchState = true;
                var mouse:Point = Laya.stage.getMousePoint();
                setPoint(mouse, _startPoint);
                setPoint(mouse, _endPoint);
                _len = _endPoint.x - _startPoint.x;
                _fireGun.onFireGunRotation(mouse, 0);
                _fireBall.onFireGunPos(mouse, _len, false);
                _prepareBall.onFireGunPos(mouse, _len, true)
            }

        }

        private function onFireGunMouseMove(e:Event):void
        {
            if (e.target.name == "Pedestal")
            {
                return
            }
            e.stopPropagation();
            if (_ballIsJump == false && _misTouchState == true)
            {
                var mouse:Point = Laya.stage.getMousePoint();
                setPoint(mouse, _endPoint);
                _len = _endPoint.x - _startPoint.x;
                _fireGun.onFireGunRotation(mouse, _len);
                _fireBall.onFireGunPos(mouse, _len, false);
                _prepareBall.onFireGunPos(mouse, _len, true)
                setPoint(mouse, _startPoint);
            }

        }

        private function onFireGunLaunch(e:Event):void
        {
            if (e.target.name == "Pedestal")
            {
                return
            }
            e.stopPropagation();
            if (_ballIsJump == false && _misTouchState == true && _fireBall.getActive() == true && chainIsCanShoot() == true)
            {
                GameSoundManager.playExcelMusic(SoundType.lAUNCH);
                var mouse:Point = Laya.stage.getMousePoint();
                _endPoint = mouse;
                _fireGun.onFire(_fireBall.type, mouse);
                _fireBall.setActive(false);
                _prepareBall.setActive(false)
                Laya.timer.once(200, this, refreshNewBall);
            }

        }

        public function chainIsCanShoot():Boolean
        {
            return true

            //            var isCan:Boolean = true;
            //            var oneChain:FightChain;
            //            for (var i:int = 0; i < ZumaMap._fightChainArr.length; i++)
            //            {
            //                oneChain = ZumaMap._fightChainArr[i];
            //                if (oneChain.canShoot() == false)
            //                {
            //                    isCan = false;
            //                }
            //            }
            //            return isCan;
        }

        //刷新一个新的球
        private function refreshNewBall():void
        {
            if (!_fireBall.getActive() || !_prepareBall.getActive())
            {
                _misTouchState = false;
                var type:Number = gameStrategy();
                _fireBall.setAniSprite(_prepareBall.type, false);
                _fireBall.setActive(true);
                _prepareBall.setActive(true);
                _prepareBall.setAniSprite(type, true);
            }
        }

        public function screenResize():void
        {
            ZumaMap.instance.screenResize();
            if (_fireGun)
            {
                _fireGun.screenResize();
            }
            if (_fireBall)
            {
                _fireBall.screenResize();
            }
            if (_prepareBall)
            {
                _prepareBall.screenResize();
            }
        }

        public function get gameState():Number
        {
            return _gameState;
        }

        public function get fireGun():FireGun
        {
            return _fireGun;
        }

        public function get ballIsJump():Boolean
        {
            return _ballIsJump;
        }

        public function set ballIsJump(value:Boolean):void
        {
            _ballIsJump = value;
        }
    }
}