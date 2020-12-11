package fight
{
    import enums.BallDepth;
    import enums.FightType;
    import enums.LevelPassType;
    import enums.ShowType;
    import enums.SoundType;

    import fight.zuma.ZumaManager;

    import fight.zuma.ZumaManager;

    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.ui.Label;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.GameSoundManager;
    import manager.UiManager;

    import model.FightM;
    import model.LoginM;

    public class FightManager
    {
        private static var _instance:FightManager;
        private var _layers:Array;
        private var _fightRoot:Sprite;//根节点

        private var _fight_up_layers:Array;
        private var _fightUiUpLayer:Sprite = null;

        private var _war_layers:Array;//战斗层
        private var _warRoot:Sprite;//战斗根节点

        private var _zuma_layers:Array;//祖玛层
        private var _zumaRoot:Sprite;//祖玛根节点

        private var _updateTime:Number = 0;

        public var _countDown:Label;

        public var _limitInterval:Number = 1;//1秒  倒计时间隔
        public var _limitUpdate:Number = 0;

        private var _exitBtton:Boolean = false;

        private var _awardArray:Array;

        public function FightManager()
        {
            var layerNode:Sprite;
            var i:int;

            _layers = [];
            _zuma_layers = [];
            _war_layers = [];
            _awardArray = [];
            _fight_up_layers = [];
            var fightBaseDepth:int = UiManager.instance.getFightBaseDepth();
            var fightUiBaseDepth:int = UiManager.instance.getFightUiBaseDepth();
            _fightRoot = new Sprite();
            _fightUiUpLayer = new Sprite();
            Laya.stage.addChild(_fightRoot);
            Laya.stage.addChild(_fightUiUpLayer);
            _fightRoot.zOrder = fightBaseDepth;
            _fightUiUpLayer.zOrder = fightUiBaseDepth;
            _warRoot = new Sprite();
            _zumaRoot = new Sprite();
            _fightRoot.addChild(_warRoot);//上方对战
            _fightRoot.addChild(_zumaRoot);//下方祖玛根节点
            _layers.push(_warRoot);
            _layers.push(_zumaRoot);
            for (i = 0; i < GameConst.fight_max_layer; i++)
            {
                layerNode = new Sprite();
                layerNode.mouseThrough = true;
                _zumaRoot.addChild(layerNode);
                _zuma_layers.push(layerNode);
            }

            for (i = 0; i < GameConst.fight_max_layer; i++)
            {
                layerNode = new Sprite();
                _warRoot.addChild(layerNode);
                _war_layers.push(layerNode);
            }

            for (i = 0; i < GameConst.fightUiUpLayer_max; i++)
            {
                layerNode = new Sprite();
                _fightUiUpLayer.addChild(layerNode);
                _fight_up_layers.push(layerNode);
            }
            CoordGm.instance;
            _warRoot.visible = false;
            initFightUiUpLayer();
            GameEventDispatch.instance.on(GameEvent.FightStart, this, start);
            GameEventDispatch.instance.on(GameEvent.FightStop, this, stop);
            GameEventDispatch.instance.on(GameEvent.GoOnGameOneTimes, this, onGoOnGameOneTimes);
            GameEventDispatch.instance.on(GameEvent.FightOverReturnMain, this, onFightOverReturnMain);
            GameEventDispatch.instance.on(GameEvent.SystemReset, this, systemReset);
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
        }

        private function initFightUiUpLayer():void
        {
            if (!_countDown)
            {
                _countDown = new Label();
                _fight_up_layers[GameConst.fightUiUpLayer_power].addChild(_countDown);
            }
            _countDown.fontSize = 40;
            _countDown.width = 315;
            _countDown.height = 40;
            _countDown.align = "center";
            _countDown.valign = 'middle';
            // _countDown.x = Laya.stage.width / 2;
            _countDown.top = 120;
            _countDown.right = 10;
            _countDown.color = "#ff0000";
            _countDown.visible = false;
        }

        public static function dispose():void
        {
            _instance = null
        }

        public static function get instance():FightManager
        {
            return _instance || (_instance = new FightManager());
        }

        public function exitGame():void
        {
            ZumaManager.instance.offAllClick();
            Laya.timer.clear(this, this.onLoop);
            _exitBtton = true;
            ZumaManager.instance.gameStop();
            removeInvalidAwardEffect(true);
            FightUpdate.removeObjs(true);
            _fightRoot.visible = false;
            _fightUiUpLayer.visible = false;
            UiManager.instance.closePanel("Account", true);
            UiManager.instance.closePanel("FightPage", true);
            UiManager.instance.loadView("MainPage");
        }

        private function start():void
        {
            FightM.instance.setFightModelReset();
            _exitBtton = false;
            FightM.instance.setSceneLimitTime(LoginM.instance.sceneId);
            if (FightM.instance.isTimeLimit == LevelPassType.TIMELIMIT)
            {
                _countDown.text = FightM.instance.getShowLimitTime();
                _countDown.visible = true;
            }
            _fightRoot.visible = true;
            _fightUiUpLayer.visible = true;
            ZumaManager.instance.init(_zumaRoot, _zuma_layers);
            //            WarManager.instance.init(_warRoot, _war_layers);
            ZumaManager.instance.gameStart();
            //            WarManager.instance.gameStart();
            screenResize();
            GameSoundManager.playExcelMusic(SoundType.BEGIN);
            Laya.timer.frameLoop(1, this, this.onLoop);
        }

        private function stop():void
        {
            pauseGame();
            FightM.instance.getReviveCount();
        }

        public function pauseGame():void
        {
            ZumaManager.instance.offAllClick();
            Laya.timer.clear(this, this.onLoop);
        }

        private function onGoOnGameOneTimes():void
        {
            Laya.timer.frameLoop(1, this, this.onLoop);
            Laya.timer.once(1000, ZumaManager.instance, ZumaManager.instance.onGoOnGameOneTimes);
            ZumaManager.instance.useBackSkill();
        }

        public function onContinueGame():void
        {
            Laya.timer.frameLoop(1, this, this.onLoop);
            Laya.timer.once(1000, ZumaManager.instance, ZumaManager.instance.onGoOnGameOneTimes);
        }

        public function oneTimeAgain():void
        {
            _exitBtton = true;
            ZumaManager.instance.gameStop();
            removeInvalidAwardEffect(true);
            FightUpdate.removeObjs(true);
            start();
        }

        private function onFightOverReturnMain():void
        {
            _exitBtton = true;
            ZumaManager.instance.gameStop();
            //            WarManager.instance.gameStop();
            removeInvalidAwardEffect(true);
            FightUpdate.removeObjs(true);
            _fightRoot.visible = false;
            _fightUiUpLayer.visible = false;
            UiManager.instance.closePanel("Account", true);
            UiManager.instance.closePanel("FightPage", true);
            UiManager.instance.loadView("MainPage");
        }

        private function systemReset():void
        {
            reset()
        }

        private function reset():void
        {
            FightUpdate.removeObjs(true);
        }

        private function onLoop():void
        {
            update(Laya.timer.delta / 1000);
        }

        public function update(delta:Number):void
        {
            _updateTime += delta;
            _limitUpdate += delta;
            while (_updateTime >= GameConst.fixed_update_time)
            {
                ZumaManager.instance.update(GameConst.fixed_update_time);
                //                WarManager.instance.update(GameConst.fixed_update_time);
                awardEffectUpdate(GameConst.fixed_update_time);
                _updateTime -= GameConst.fixed_update_time;
            }
            removeInvalidAwardEffect();
            if (FightM.instance.isTimeLimit == LevelPassType.TIMELIMIT)
            {
                while (_limitUpdate >= _limitInterval)
                {
                    FightM.instance.countDown();
                    _countDown.text = FightM.instance.getShowLimitTime();
                    _limitUpdate -= _limitInterval
                    if (FightM.instance.limitTime <= 0)
                    {
                        GameEventDispatch.instance.event(GameEvent.GameTimeOut);
                    }
                }
            }

        }

        private function awardEffectUpdate(delta:Number):void
        {
            var aEffect:AwardEffect = null;
            for (var i:int = 0; i < _awardArray.length; i++)
            {
                aEffect = _awardArray[i] as AwardEffect;
                aEffect.update(delta);
            }
        }

        //怪物血量的伤害动画
        public function showMonsterBooldChange(monster:*, value):void
        {
            if (Math.abs(value) > 0)
            {
                var aEffect:AwardEffect = AwardEffect.create(Math.abs(value), monster.getHurtAniPoint(),
                        GameConst.font_type_plot_type_battery,
                        _fight_up_layers[GameConst.fightUiUpLayer_ani], 0);
                _awardArray.push(aEffect);
            }
            else
            {

            }
        }

        //球上能量数量的动画或是分数的动画
        public function showBallPowerChange(point:Point, value:Number, isDesign:Boolean = false):void
        {
            if (Math.abs(value) > 0)
            {
                var aEffect:AwardEffect;
                if (isDesign == true)
                {
                    aEffect = AwardEffect.create(Math.abs(value), CoordGm.instance.zumaAllDesToScr(point),
                            GameConst.font_type_own,
                            _fight_up_layers[GameConst.fightUiUpLayer_ani], 0);
                } else
                {
                    aEffect = AwardEffect.create(Math.abs(value), point,
                            GameConst.font_type_own,
                            _fight_up_layers[GameConst.fightUiUpLayer_ani], 0);
                }
                _awardArray.push(aEffect);
            }
            else
            {

            }
        }

        //war中祖玛消除后攻击怪物的动画
        public function showBoomChange(point:Point, actionName:String, isDesignPos:Boolean = false):void
        {
            SkillEffect.create(_fight_up_layers[GameConst.fightUiUpLayer_ani], actionName, point, FightType.UP, isDesignPos);
        }

        private var _removeArray:Array = [];

        private function removeInvalidAwardEffect(removeAll:Boolean = false):void
        {
            _removeArray.length = 0;
            for (var i:int = 0; i < _awardArray.length; i++)
            {
                var aEffect:AwardEffect = _awardArray[i] as AwardEffect;
                if (!aEffect.isValid() || removeAll)
                {
                    _removeArray.push(aEffect);
                }
            }
            var count:int = _removeArray.length;
            for (var j:int = 0; j < count; j++)
            {
                var removeEffect:AwardEffect = _removeArray[j] as AwardEffect;
                removeEffect.destroy();
                for (var k:int = 0; k < _awardArray.length; k++)
                {
                    if (_awardArray[k] == removeEffect)
                    {
                        _awardArray.splice(k, 1);
                        break;
                    }
                }
            }
        }

        private function screenResize():void
        {
            _zumaRoot.y = Laya.stage.height * GameConst.war_percent;
            _countDown.x = Laya.stage.width - 315 - 10; // 倒计时宽度和距右边界距离
            _countDown.scale(CoordGm.instance.minScale, CoordGm.instance.minScale);
            ZumaManager.instance.screenResize();
            //            WarManager.instance.screenResize();
        }

        public function get exitBtton():Boolean
        {
            return _exitBtton;
        }
    }
}