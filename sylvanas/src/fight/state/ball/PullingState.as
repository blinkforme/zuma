package fight.state.ball
{
    import enums.Direction;

    import fight.zuma.Ball;
    import fight.power.PullBackPower;
    import fight.power.RepelingPower;

    import manager.GameConst;

    import struct.fsm.State;

    //回退状态
    public class PullingState extends State
    {

        private static var _instance:PullingState;

        public function PullingState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
            var ball:Ball = owner as Ball
            ball.power = new PullBackPower(ball, ball.chain)
        }

        override public function execute(owner:Object):void
        {
            super.execute(owner);
            var ball:Ball = owner as Ball
            var power:PullBackPower = ball.power as PullBackPower
            power.push(GameConst.fixed_update_time)

            if (ball.isBackTouch)
            {
                var nextBall:Ball = ball.getNextBall()
                if (nextBall.isInserting)
                {
                    ball.fsm.changeState(StaticState.instance)
                } else
                {
                    var balls:Array = ball.getSameColorBalls()
                    var lastNextBall:Ball = balls[balls.length - 1].getNextTouchedBall()

                    if (lastNextBall)
                    {
                        if (lastNextBall.isInserting)
                        {
                            lastNextBall = lastNextBall.getNextTouchedOnlineBall()
                        }
                        lastNextBall.power = new RepelingPower(lastNextBall, lastNextBall.chain, ball.pullPowerLevel * Ball.RADIUS + Ball.RADIUS, 400, Direction.Back)
                        lastNextBall.fsm.changeState(RepelingState.instance)
                    }


                    if (balls.length >= 3)
                    {
                        var firstPrevBall:Ball = balls[0].getPrevTouchedBall()
                        if (firstPrevBall)
                        {
                            firstPrevBall.pullPowerLevel = ball.pullPowerLevel + 1
                        }

                        ball.chain.doHitEliminate(balls)
                        for (var i:Number = 0; i < balls.length; i++)
                        {
                            var tempBall:Ball = balls[i];
                            tempBall.fsm.changeState(ExplodeState.instance)
                        }
                    } else
                    {
                        ball.fsm.changeState(StaticState.instance)
                    }
                }

            } else
            {
                checkPullState(ball)
            }
        }

        public function checkPullState(ball:Ball):void
        {
            var nextBall:Ball = ball.getNextBall()
            if (ball.fsm.isInState(StaticState))
            {
                if (nextBall)
                {
                    if (nextBall.fsm.isInState(StaticState) && (ball.color != nextBall.color))
                    {

                    } else
                    {
                        ball.fsm.changeState(StaticState.instance)
                    }
                } else
                {
                    ball.fsm.changeState(StaticState.instance)
                }
            }

        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
            var ball:Ball = owner as Ball
            ball.power = null
        }

        public static function get instance():PullingState
        {
            return _instance || (_instance = new PullingState());
        }

    }
}
