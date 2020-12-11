package manager
{

    import control.FightC;
    import control.LoginC;
    import control.MsgC;
    import control.UserInfoC;
    import control.WxC;
    import control.WxShareC;

    import model.AccountM;
    import model.FightM;

    import model.LoadTipM;
    import model.LoginInfoM;
    import model.LoginM;
    import model.MsgM;
    import model.UserInfoM;

    public class GameInit
    {
        private static var _instance:GameInit;

        public function GameInit()
        {

        }

        public static function get instance():GameInit
        {
            return _instance || (_instance = new GameInit());
        }

        public function ModelInit():void
        {

            LoginInfoM.instance;
            LoginM.instance;
            LoadTipM.instance;
            UserInfoM.instance;
            MsgM.instance;
            AccountM.instance;
            FightM.instance;

        }

        public function ControlInit():void
        {
            LoginC.instance;
            FightC.instance;
            WxC.instance;
            WxShareC.instance;
            MsgC.instance;
            UserInfoC.instance;
        }

        public function init():void
        {
            ModelInit();
            ControlInit();
        }
    }
}
