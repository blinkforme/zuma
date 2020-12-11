package fight.state.ball
{
    import enums.BallDepth;

    import fight.zuma.Ball;
    import fight.power.InsertPower;

    import manager.GameConst;

    import struct.fsm.State;

    public class InsertState extends State
    {
        private static var _instance:InsertState;

        public function InsertState()
        {
        }


        public function checkTouch(ball:Ball):void
        {
            if (!ball.isBackTouch)
            {
                var nextBall:Ball = ball.getNextBall()
                if (nextBall)
                {
                    var isBackTouch:Boolean = (ball.targetPosition.curDistance - nextBall.targetPosition.curDistance <= Ball.DIAMETER)
                    ball.isBackTouch = isBackTouch
                    nextBall.isForwardTouch = isBackTouch
                } else
                {
                    ball.isBackTouch = false
                }
            }

            if (!ball.isForwardTouch)
            {
                var prevBall:Ball = ball.getPrevBall()
                if (prevBall)
                {
                    var isForwardTouch:Boolean = (prevBall.targetPosition.curDistance - ball.targetPosition.curDistance <= Ball.DIAMETER)
                    ball.isForwardTouch = isForwardTouch
                    prevBall.isBackTouch = isForwardTouch
                } else
                {
                    ball.isForwardTouch = false
                }
            }


            //            var prevBall:Ball = ball.getPrevBall()
            //            if (ball.isInserting)
            //            {
            //                if (ball.isInsertFront)
            //                {
            //                    if (prevBall && !prevBall.isSqueezing)
            //                    {
            //                        if (Ball.isTwoBallTouched(ball, prevBall))
            //                        {
            //                            ball.isForwardTouch = true
            //                            prevBall.isBackTouch = true
            //                            if (!prevBall.isInserting)
            //                            {
            //                                prevBall.fsm.changeState(SqueezeState.instance)
            //                            }
            //                        }
            //                    }
            //                } else
            //                {
            //                    var nextBall:Ball = ball.getNextBall()
            //
            //                    if (nextBall)
            //                    {
            //                        if (Ball.isTwoBallTouched(ball, nextBall))
            //                        {
            //                            ball.isBackTouch = true
            //                            nextBall.isForwardTouch = true
            //                            if (!prevBall.isInserting)
            //                            {
            //                                prevBall.fsm.changeState(SqueezeState.instance)
            //                            }
            //                        }
            //                    }
            //                }
            //
            //            }
        }

        override public function enter(owner:Object):void
        {
            super.enter(owner);
            var ball:Ball = owner as Ball
            checkTouch(ball)
            ball.power = new InsertPower(ball, ball.chain)
        }

        override public function execute(owner:Object):void
        {
            console.log("insert state execute")
            super.execute(owner);
            var ball:Ball = owner as Ball
            checkTouch(ball)

            var power:InsertPower = ball.power as InsertPower
            power.execute(GameConst.fixed_update_time)


            if (!power.isValid)
            {
                ball.fsm.changeState(StaticState.instance)

                var balls:Array = ball.getSameColorBalls()
                if (balls.length >= 3)
                {
                    ball.chain.doHitEliminate(balls)
                    for (var i:Number = 0; i < balls.length; i++)
                    {
                        var tempBall:Ball = balls[i];
                        tempBall.fsm.changeState(ExplodeState.instance)
                    }
                }
            }
        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
            var ball:Ball = owner as Ball
            ball.power = null
            ball.curPos = ball.targetPosition
            ball.calcBallZOrder()
        }

        public static function get instance():InsertState
        {
            return _instance || (_instance = new InsertState());
        }

    }
}
