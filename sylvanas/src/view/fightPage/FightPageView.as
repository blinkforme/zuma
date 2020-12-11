package view.fightPage
{
    import conf.cfg_goods;

    import control.WxC;
    import control.WxShareC;

    import enums.SkillType;

    import fight.CoordGm;

    import fight.zuma.ZumaManager;

    import manager.ApiManager;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;

    import model.FightM;
    import model.LoginInfoM;
    import model.LoginM;

    import ui.sylvanas.FightPageUI;

    import laya.events.Event;

    import fight.FightManager;

    public class FightPageView extends FightPageUI implements ResVo
    {

        private var _startAniOnOff:Object = {32: 0, 33: 0};
        private var _timer:Number = 1;

        public function FightPageView()
        {

        }

        public function StartGames(param:Object = {}):void
        {
            this.hitTestPrior = false;
            LoginInfoM.instance.mainPageShow = true;
            initUI();
            updatePowerData();
            btnBack.on(Event.CLICK, this, exitGame);
            screenResize();
        }

        public function onFrozenBtn(e:Event):void
        {

            if (FightM.instance.skillNumArr[SkillType.FTOZEN] <= 0)
            {
                var query:String = 'uid=' + SkillType.FTOZEN;
                WxShareC.wxShare(1, 1, query);
            } else
            {
                FightM.instance.skillNumArr[SkillType.FTOZEN] -= 1;
                onUpdateSkillState();
                ApiManager.instance.saveUserSkill();
                ZumaManager.instance.useFreezeSkill();
            }
        }

        public function onGoBackBtn(e:Event):void
        {
            if (FightM.instance.skillNumArr[SkillType.GOBACK] <= 0)
            {
                var query:String = 'uid=' + SkillType.GOBACK;
                WxShareC.wxShare(1, 1, query);
            } else
            {
                FightM.instance.skillNumArr[SkillType.GOBACK] -= 1;
                onUpdateSkillState();
                ApiManager.instance.saveUserSkill();
                ZumaManager.instance.useBackSkill();
            }
        }

        private function initUI():void
        {
            _startAniOnOff = {32: 0, 33: 0};
            checkpointLable.text = "关卡" + LoginM.instance.sceneId;
            frozenBtn.on(Event.MOUSE_DOWN, this, stopEvent);
            frozenBtn.on(Event.CLICK, this, onFrozenBtn);
            goBackBtn.on(Event.MOUSE_DOWN, this, stopEvent);
            goBackBtn.on(Event.CLICK, this, onGoBackBtn);
            onUpdateSkillState();
        }

        public function stopEvent(e:Event):void
        {
            e.stopPropagation();
        }

        private function onUpdateSkillState():void
        {
            if (FightM.instance.skillNumArr[SkillType.FTOZEN] <= 0)
            {
                frozenBtn.skin = cfg_goods.instance("" + SkillType.FTOZEN).no_skill_icon;
                frozenLabel.text = "X0";
                _startAniOnOff[SkillType.FTOZEN] = 1;
            } else
            {
                _startAniOnOff[SkillType.FTOZEN] = 0;
                frozenBtn.skin = cfg_goods.instance("" + SkillType.FTOZEN).icon;
                frozenBtn.scale(1, 1);
                frozenLabel.text = "X" + FightM.instance.skillNumArr[SkillType.FTOZEN];
            }
            if (FightM.instance.skillNumArr[SkillType.GOBACK] <= 0)
            {
                goBackBtn.skin = cfg_goods.instance("" + SkillType.GOBACK).no_skill_icon;
                goBackLabel.text = "X0";
                _startAniOnOff[SkillType.GOBACK] = 1;
            } else
            {
                _startAniOnOff[SkillType.GOBACK] = 0;
                goBackBtn.skin = cfg_goods.instance("" + SkillType.GOBACK).icon;
                goBackBtn.scale(1, 1);
                goBackLabel.text = "X" + FightM.instance.skillNumArr[SkillType.GOBACK];
            }
        }

        private var _frozenScale:Number = 0
        private var _goBackScale:Number = 0

        public function playNoSkillAni():void
        {
            if (_startAniOnOff[SkillType.FTOZEN] == true)
            {
                if (frozenBtn.scaleX >= 1.5)
                {
                    _frozenScale = -_timer / 100;
                } else if (frozenBtn.scaleX <= 1)
                {
                    _frozenScale = _timer / 100;
                }
                frozenBtn.scaleX += _frozenScale
                frozenBtn.scaleY += _frozenScale
            }
            if (_startAniOnOff[SkillType.GOBACK] == true)
            {
                if (goBackBtn.scaleX >= 1.5)
                {
                    _goBackScale = -_timer / 100;
                } else if (goBackBtn.scaleX <= 1)
                {
                    _goBackScale = _timer / 100;
                }
                goBackBtn.scaleX += _goBackScale
                goBackBtn.scaleY += _goBackScale
            }
        }

        // 退出游戏
        private function exitGame():void
        {
            FightManager.instance.exitGame();
        }

        private function screenResize():void
        {
            banner.width = Laya.stage.width;
            banner.height = Laya.stage.width / 720 * 250;
            topBg.width = Laya.stage.width + 5;
            topBg.height = Laya.stage.height * GameConst.war_percent + 5;
            frozenBox.top = topBg.height + CoordGm.instance.zumaMapXY().y + 720 * CoordGm.instance.minScale + 60;
            goBackBox.top = topBg.height + CoordGm.instance.zumaMapXY().y + 720 * CoordGm.instance.minScale + 60;
            this.size(Laya.stage.width, Laya.stage.height);
        }

        private function updatePowerData():void
        {
            scoreLable.text = FightM.instance.sceneScore + "";
            checkpointBar.value = FightM.instance.sceneScore / FightM.instance.needScore;
        }


        //注册消息发送事件
        public function register():void
        {
            Laya.timer.loop(_timer, this, playNoSkillAni);
            LoginM.instance.pageId = GameConst.FIGHT_PAGE;
            GameEventDispatch.instance.on(GameEvent.UpdateSkillState, this, onUpdateSkillState);
            GameEventDispatch.instance.on(GameEvent.UpdatePowerData, this, updatePowerData);
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
        }

        //取消注册的消息发送事件
        public function unRegister():void
        {
            Laya.timer.clear(this, playNoSkillAni);
            GameEventDispatch.instance.off(GameEvent.UpdateSkillState, this, onUpdateSkillState);
            GameEventDispatch.instance.off(GameEvent.UpdatePowerData, this, updatePowerData);
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
        }
    }
}