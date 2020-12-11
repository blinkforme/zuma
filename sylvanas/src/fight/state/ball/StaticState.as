package fight.state.ball
{
    import fight.zuma.Ball;

    import struct.fsm.State;

    public class StaticState extends State
    {

        private static var _instance:StaticState;

        public function StaticState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
            var ball:Ball = owner as Ball
            ball.rotateSpeed =ball.chain.static_power.nowSpeed()
        }

        override public function execute(owner:Object):void
        {
            super.execute(owner);
            var ball:Ball = owner as Ball
            checkPullState(ball)
        }

        public function checkPullState(ball:Ball):void
        {
            var nextBall:Ball = ball.getNextBall()
            if (nextBall)
            {
                if (!ball.isBackTouch)
                {
                    if (ball.color == nextBall.color && nextBall.fsm.isInState(StaticState))
                    {
                        ball.fsm.changeState(PullingState.instance)
                        return
                    }
                }
            }
            ball.pullPowerLevel = 1
        }


        override public function exit(owner:Object):void
        {
            super.exit(owner);
        }

        public static function get instance():StaticState
        {
            return _instance || (_instance = new StaticState());
        }

    }
}
