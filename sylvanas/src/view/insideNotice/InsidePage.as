package view.insideNotice
{
    import control.WxC;

    import laya.events.Event;

    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;
    import manager.UiManager;

    import ui.sylvanas.InsideNoticePageUI;

    public class InsidePage extends InsideNoticePageUI implements ResVo
    {
        private var _startX:Number = 0;
        private var _startY:Number = 0;

        public function InsidePage()
        {
            super();
        }


        public function StartGames(parm:Object = null):void
        {
            this.hitTestPrior = false;
            _startX = this.x;
            _startY = this.y;

            screenResize();
            confirm_btn.visible = true
            confirm_btn.on(Event.CLICK, this, clickConfirm);
            initInfo()
        }

        private function initInfo():void
        {
            if (WxC.isInMiniGame())
            {
                if (WxC.author == 2)
                {
                    confirm_btn.visible = true
                    WxC.createUserInfoButton("InsideNotice")
                }
            }
        }

        private function clickConfirm():void
        {
            UiManager.instance.closePanel("InsideNotice", false);
        }


        private function screenResize():void
        {
            bmask.width = Laya.stage.width * 1.5;
            bmask.height = Laya.stage.height * 1.5;
            this.size(Laya.stage.width, Laya.stage.height);
        }

        public function register():void
        {
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
        }

        public function unRegister():void
        {
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
        }
    }
}
