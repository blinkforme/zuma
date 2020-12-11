package view.award
{
    import conf.cfg_goods;

    import enums.SkillType;

    import fight.FightManager;

    import fight.zuma.ZumaManager;

    import laya.events.Event;

    import manager.ApiManager;

    import manager.GameConst;

    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;

    import control.WxShareC;

    import manager.UiManager;

    import model.AwardM;

    import model.FightM;

    import ui.sylvanas.AwardPageUI;

    public class AwardView extends AwardPageUI implements ResVo
    {
        public function AwardView():void
        {

        }

        public function StartGames(parm:Object = null):void
        {
            this.hitTestPrior = true;
            this.on(Event.CLICK, this, null);
            initDataSource();
            goOnBtn.on(Event.CLICK, this, onGoOnBtn);
            screenResize();
        }

        private function initDataSource():void
        {
            FightManager.instance.pauseGame();
            FightM.instance.skillNumArr[AwardM.instance.awardId] += AwardM.instance.awardNum;
            ApiManager.instance.saveUserSkill();
            GameEventDispatch.instance.event(GameEvent.UpdateSkillState);
            awardImage.skin = cfg_goods.instance("" + AwardM.instance.awardId).icon;
            awardNum.text = AwardM.instance.awardNum + "";
            awardName.text = cfg_goods.instance("" + AwardM.instance.awardId).name;
        }

        //分享双倍领取
        private function onGoOnBtn():void
        {
            UiManager.instance.closePanel("Award", true);
            FightManager.instance.onContinueGame();
        }

        private function screenResize():void
        {
            bgmask.width = GameConst.design_width * 1.6;
            bgmask.height = GameConst.design_height * 1.6;
            this.size(Laya.stage.width, Laya.stage.height);
        }


        //注册消息发送事件
        public function register():void
        {
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
        }

        //取消注册的消息发送事件
        public function unRegister():void
        {
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
        }
    }
}