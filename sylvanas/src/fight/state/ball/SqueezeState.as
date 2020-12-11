package fight.state.ball
{
    import fight.zuma.Ball;

    import manager.GameConst;

    import struct.fsm.State;

    //插入被挤压状态
    public class SqueezeState extends State
    {
        private static var _instance:SqueezeState;

        public function SqueezeState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
        }


        public function squeeze(ball:Ball, delta:Number):void
        {
            var prevBall:Ball = ball.getPrevBall()
            var nextBall:Ball = ball.getNextBall()

            if (nextBall)
            {
                var overDistance:Number = ball.targetPosition.curDistance - nextBall.targetPosition.curDistance
                if (overDistance < Ball.DIAMETER)
                {
                    var pushDistance:Number = ball.getSqueezeSpeed() * delta
                    if (pushDistance > Ball.DIAMETER - overDistance)
                    {
                        pushDistance = Ball.DIAMETER - overDistance
                        ball.pushForward(pushDistance)
                        ball.fsm.changeState(StaticState.instance)
                    } else
                    {
                        ball.pushForward(pushDistance)
                    }
                } else
                {
                    ball.fsm.changeState(StaticState.instance)
                }
            }
        }


        override public function execute(owner:Object):void
        {
            super.execute(owner);
            var ball:Ball = owner as Ball

            squeeze(ball, GameConst.fixed_update_time)

        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
        }

        public static function get instance():SqueezeState
        {
            return _instance || (_instance = new SqueezeState());
        }

    }
}
