package view.login
{
    import enums.UiType;

    import manager.BaseView;
    import manager.PanelVo;

    public class Login extends BaseView implements PanelVo
    {
        public function Login()
        {
            super();
        }

        public function get pngNum():int
        {
            return 0;
        }

        public function startGame(parm:Object = null, name:String = null):void
        {
            creatPanel(LoginView, parm, name);
        }

        public function get uiType():String
        {
            return UiType.UI_TYPE_DLG;
        }
    }
}
