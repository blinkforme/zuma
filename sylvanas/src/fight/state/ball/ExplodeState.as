package fight.state.ball
{
    import fight.zuma.Ball;

    import struct.fsm.State;

    public class ExplodeState extends State
    {
        private static var _instance:ExplodeState;

        public function ExplodeState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
            var ball:Ball = owner as Ball
            ball.startExplode()
        }

        override public function execute(owner:Object):void
        {
            super.execute(owner);
            var ball:Ball = owner as Ball
            if (!ball.isExploding)
            {
                ball.fsm.changeState(EndState.instance)
                ball.destroy()
            }
        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
        }

        public static function get instance():ExplodeState
        {
            return _instance || (_instance = new ExplodeState());
        }

    }
}
