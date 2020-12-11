package view.friendsRanking
{
    import manager.GameConst;

    import manager.ResVo;
    import manager.GameEventDispatch;
    import manager.GameEvent;
    import manager.UiManager;

    import laya.events.Event;
    import laya.ui.WXOpenDataViewer;

    import ui.sylvanas.FriendsRankingUI;

    import control.WxShareC;

    public class FriendsRankingView extends FriendsRankingUI implements ResVo
    {

        private var _arrData:Array = [];

        private var rankSprite:WXOpenDataViewer = null;

        public function FriendsRankingView()
        {

        }

        public function StartGames(param:Object = {}):void
        {
            inviteBtn.on(Event.CLICK, this, onInviteBtn);
            btnClose.on(Event.CLICK, this, closePanel);
            if (WxShareC.isInMiniGame())
            {
                // 发送信息到开放域
                openData.postMsg({
                    type: 2
                });
            }
        }

        private function onInviteBtn():void
        {
            var query:String = 'uid=';
            WxShareC.wxShare(1, 1, query);
        }

        // 关闭弹框
        private function closePanel(e):void
        {
            UiManager.instance.closePanel("FriendsRanking", false);
        }

        private function screenResize():void
        {
            btnClose.width = Laya.stage.width * 1.6;
            btnClose.height = Laya.stage.height * 1.6;
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