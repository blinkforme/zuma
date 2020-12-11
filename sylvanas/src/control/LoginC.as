package control
{
    import enums.ShowType;

    import laya.utils.Browser;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.GameLoader;
    import manager.UiManager;

    import model.LoadResM;
    import model.LoginInfoM;
    import model.LoginM;

    import struct.QuitTipInfo;

    public class LoginC
    {
        private static var _instance:LoginC;

        public function LoginC()
        {
            GameEventDispatch.instance.on(GameEvent.StartLoad, this, startLoad);
            GameEventDispatch.instance.on(GameEvent.RestInRoom, this, resetRoom);
//            GameEventDispatch.instance.on(GameEvent.ExitsGame, this, start);
            GameEventDispatch.instance.on(GameEvent.AndroidReturnKey, this, gameReturn);
            returnMain();
        }

        private function gameReturn():void
        {
            if (LoginM.instance.pageId == GameConst.FIGHT_PAGE)
            {
                tip();
            } else if (LoginM.instance.pageId == GameConst.MAIN_PAGE)
            {
                tipTwo();
            }
        }

        private function start():void
        {
            if (WxC.isInMiniGame())
            {

            } else if (LoginInfoM.instance.fromAndroid())
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "AndroidInterface.exitApp()")
                __JS__("AndroidInterface.exitApp()");
            } else
            {
                Browser.window.top.postMessage("close", "*");
            }

        }

        private function resetRoom():void
        {
            GameEventDispatch.instance.event(GameEvent.SingleFightStart, null);
        }

        private function returnMain():void
        {
            if (!WxC.isInMiniGame())
            {
                Browser.window.addEventListener('message', function (event)
                {
                    if (event.data == 'exit_game')
                    {
                        if (LoginM.instance.pageId == GameConst.FIGHT_PAGE)
                        {
                            tip();
                        } else if (LoginM.instance.pageId == GameConst.MAIN_PAGE)
                        {
                            tipTwo();
                        }
                    }

                });
            }
        }

        public function tip():void
        {
            var info:QuitTipInfo = new QuitTipInfo();
            info.state = GameConst.quit_state_left_cancel_right_confirm;
            info.content = "是否退出房间？";
            info.confirmEvent = GameEvent.ReturnConfirm;
            info.autoCloseTime = 10;
            GameEventDispatch.instance.event(GameEvent.QuitTip, info);
        }

        public function tipTwo():void
        {
            var info:QuitTipInfo = new QuitTipInfo();
            info.state = GameConst.quit_state_left_cancel_right_confirm;
            info.content = "真的要退出游戏吗";
            info.confirmEvent = GameEvent.ExitsGame;
            info.autoCloseTime = 10;
            GameEventDispatch.instance.event(GameEvent.QuitTip, info);
        }


        private function startLoad(data:*):void
        {
            if (data == GameConst.loadFightState)
            {
                LoginM.instance.loginState = GameConst.loadFightState;
                LoginM.instance.prePlayAniArr = LoadResM.instance.normalScenePrePlayAni;

                LoginM.instance.resArr = LoadResM.instance.firstSceneArr;
                LoginM.instance.spineArr = LoadResM.instance.firstSceneSpineArr;

            }
            UiManager.instance.loadView("Load");
        }

        public function beginLogin():void
        {
            UiManager.instance.loadView("Login");
        }

        //登陆API成功后通用接口
        public function apiLoginSuccess(result:Object, is_visitor:Boolean = false):void
        {
            var data:Object = result.data;

            if (!GameLoader.manifest_name || GameLoader.manifest_name.length <= 0)
            {
                GameLoader.manifest_name = data.version;
            }

            LoginInfoM.instance.token = data['access_token']
            LoginInfoM.instance.server_name = data['server_name']
            LoginInfoM.instance.server_domain = data['server_domain']
            LoginInfoM.instance.is_new = data['is_new']

            LoginInfoM.instance.platform = data["platform"]
            LoginInfoM.instance.provider_id = data["provider_id"];
            LoginInfoM.instance.game_status = data['game_status'];
            LoginInfoM.instance.is_visitor = is_visitor

        }

        public static function get instance():LoginC
        {
            return _instance || (_instance = new LoginC());
        }
    }
}
