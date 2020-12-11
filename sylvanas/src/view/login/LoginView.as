package view.login
{
    import laya.events.Event;
    import laya.events.Keyboard;

    import manager.ApiManager;

    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;
    import manager.UiManager;

    import model.LoginInfoM;
import model.SceneM;

import ui.sylvanas.LoginUI

    public class LoginView extends LoginUI implements ResVo
    {

        public function LoginView()
        {
            LoginInfoM.instance.isLoginView = true
            super();
        }

        public var isLogin = false

        public function StartGames(parm:Object = null):void
        {
            btn_login.on(Event.CLICK, this, onLoginFuction);

            name_input.on(Event.KEY_DOWN, this, onKeyDown)
            name_input.focus = true

            ENV.isLoginView = false
        }

        public function onKeyDown(e):void
        {
            var keyCode = e["keyCode"]
            if (keyCode == Keyboard.ENTER)
            {
                if (name_input.text && name_input.text.length > 0)
                {
                    if (isLogin)
                    {
                        GameEventDispatch.instance.event(GameEvent.MsgTipContent, "已经登陆了，别按了");
                        return
                    }

                    onLoginFuction()

                    isLogin = true
                    name_input.gray = true
                    name_input.focus = false
                } else
                {
                    GameEventDispatch.instance.event(GameEvent.MsgTipContent, "请输入用户名");
                }
            }
        }


        private function onLoginFuction():void
        {
            if (name_input.text && name_input.text.length > 0)
            {
                var name:String = this.name_input.text;
                LoginInfoM.instance.name = this.name_input.text;
                var params:String = 'third_token=' + name;
                ApiManager.instance.login(params, this.loginRequest);
            } else
            {
                GameEventDispatch.instance.event(GameEvent.MsgTipContent, "请输入用户名");
            }
        }

        private function loginRequest(result):void
        {
            if (result.status)
            {
                var data:Object = result.data;

                LoginInfoM.instance.token = data['access_token']
                LoginInfoM.instance.server_name = data['server_name']
                LoginInfoM.instance.server_domain = data['api_domain']
                LoginInfoM.instance.is_new = data['is_new']

                LoginInfoM.instance.isLoginView = true;
                LoginInfoM.instance.loginFinish = true;
                SceneM.instance.getSceneInfoComplete(result);
                UiManager.instance.loadView("Load");
            }
        }

        private function closePage():void
        {
            UiManager.instance.closePanel("Login", true);
        }


        public function register():void
        {
            GameEventDispatch.instance.once(GameEvent.EnterFightPage, this, closePage);
            GameEventDispatch.instance.once(GameEvent.ExitLoginView, this, closePage);
        }


        public function unRegister():void
        {
            GameEventDispatch.instance.off(GameEvent.EnterFightPage, this, closePage);
            GameEventDispatch.instance.off(GameEvent.ExitLoginView, this, closePage);
        }
    }
}
