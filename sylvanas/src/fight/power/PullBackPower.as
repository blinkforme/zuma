package fight.power
{
    import fight.zuma.Ball;
    import fight.FightChain;
    import fight.LinePosition;

    public class PullBackPower extends PowerBase
    {
        private var totalBackDistance:Number

        //拉扯加速度
        private var pullAcceleration:Number = 800

        //拉扯最大速度
        private var pullMaxSpeed:Number = 800

        private var _round:Number;

        public function PullBackPower(ball:Ball, chain:FightChain, round:Number = 1)
        {
            super(ball, chain);
            _round = round
            totalBackDistance = _round * Ball.RADIUS
        }

        public function get round():Number
        {
            return _round;
        }

        public function set round(value:Number):void
        {
            _round = value;
        }

        public function getTargetPosition():LinePosition
        {
            var nextBall:Ball = ball.getNextBall()
            if (nextBall && nextBall.color == ball.color)
            {
                return nextBall.targetPosition.copy().move(Ball.DIAMETER)

            } else
            {
                return null
            }

        }

        override public function nextStep(delta:Number):Number
        {
            var backSpeed:Number
            if (totalTime * pullAcceleration >= pullMaxSpeed)
            {
                backSpeed = pullMaxSpeed
            } else
            {
                backSpeed = totalTime * pullAcceleration
            }
            var backDistance:Number = backSpeed * delta

            var targetPosition:LinePosition = getTargetPosition()
            if (targetPosition)
            {
                if (ball.curPos.curDistance - backDistance < targetPosition.curDistance)
                {
                    ball.isBackTouch = true
                    if (ball.getNextBall())
                    {
                        ball.getNextBall().isForwardTouch = true
                    }

                    return targetPosition.curDistance - ball.curPos.curDistance
                } else
                {
                    return -backDistance
                }
            } else
            {
                isValid = false
                return 0
            }


        }

        override public function destory():void
        {

        }

        public function moveBall(delta:Number):void
        {
            if (!ball.isBackTouch)
            {
                ball.pull(nextStep(delta))
            }
        }

        override public function push(delta:Number):void
        {
            totalTime = totalTime + delta

            moveBall(delta)
        }

    }
}
