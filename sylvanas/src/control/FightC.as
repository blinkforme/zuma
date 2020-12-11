package control
{
    import enums.ShowType;

    import fight.Rabbit;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.UiManager;
    import manager.WebSocketManager;

    import model.FightM;
    import model.RoleM;

    import proto.ProtoSeatInfo;
    import manager.ApiManager;
    import model.LoginInfoM;

    public class FightC
    {
        private static var _instance:FightC;

        public function FightC()
        {
            GameEventDispatch.instance.on(GameEvent.SingleFightStart, this, singleFightStart);

            // GameEventDispatch.instance.on(GameEvent.LeaveRoom, this, leaveRoom);

            // GameEventDispatch.instance.on(GameEvent.SystemReset, this, systemReset);
        }

        private function singleFightStart():void
        {
            trace("开始单机模式")
            GameEventDispatch.instance.event(GameEvent.FightStart, null);
            UiManager.instance.closePanel("Load", false);
            UiManager.instance.loadView("FightPage",false,ShowType.SMALL_TO_BIG);
        }

        public static function get instance():FightC
        {
            return _instance || (_instance = new FightC());
        }

    }
}
