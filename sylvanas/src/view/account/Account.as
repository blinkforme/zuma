package view.account
{
    import enums.UiType;

    import manager.BaseView;
    import manager.PanelVo;

    public class Account extends BaseView implements PanelVo
    {
        public function Account()
        {
            super();
        }

        public function get pngNum():int
        {
            return 0;
        }

        public function startGame(parm:Object = null, name:String = null):void
        {
            creatPanel(AccountView, parm, name);

        }

        public function get uiType():String
        {
            return UiType.UI_TYPE_ERROR_TIP;
        }
    }
}