package fight.state.ball
{
    import fight.zuma.Ball;
    import fight.power.RepelingPower;

    import manager.GameConst;

    import struct.fsm.State;

    //回退状态
    public class RepelingState extends State
    {

        private static var _instance:RepelingState;

        public function RepelingState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
            var ball:Ball = owner as Ball
        }

        override public function execute(owner:Object):void
        {
            super.execute(owner);
            var ball:Ball = owner as Ball
            var power:RepelingPower = ball.power as RepelingPower
            power.push(GameConst.fixed_update_time)

            if (!power.isValid)
            {
                ball.fsm.changeState(StaticState.instance)
            }
        }


        override public function exit(owner:Object):void
        {
            super.exit(owner);
            var ball:Ball = owner as Ball
        }

        public static function get instance():RepelingState
        {
            return _instance || (_instance = new RepelingState());
        }

    }
}
