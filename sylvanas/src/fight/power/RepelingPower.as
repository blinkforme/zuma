package fight.power
{
    import enums.Direction;

    import fight.zuma.Ball;
    import fight.FightChain;

    public class RepelingPower extends PowerBase
    {

        private var _limit_distance:Number;
        private var _speed:Number
        private var _direction:Number

        public function RepelingPower(ball:Ball, chain:FightChain, limit_distance:Number, speed:Number, direction:Number)
        {
            super(ball, chain);
            this._limit_distance = limit_distance
            this._speed = speed
            this._direction = direction
        }


        override public function nextStep(delta:Number):Number
        {
            if (totalTime * speed > limit_distance)
            {
                isValid = false
                return 0
            } else
            {
                if (direction == Direction.Forward)
                {
                    return speed * delta
                } else
                {
                    return -speed * delta
                }
            }
        }


        public function getJudgeBall():Ball
        {

            var nowBall:Ball = ball
            var prevTouchBall:Ball = nowBall.getPrevTouchedBall()

            while (prevTouchBall)
            {
                nowBall = prevTouchBall
                prevTouchBall = prevTouchBall.getPrevTouchedBall()
            }
            return nowBall
        }

        override public function push(delta:Number):void
        {
            totalTime = totalTime + delta
            var step:Number = nextStep(delta)
            if (_direction == Direction.Forward)
            {
                getJudgeBall().pushForward(step)
            } else if (_direction == Direction.Back)
            {
                getJudgeBall().pushBack(step)
            }
        }

        public function get limit_distance():Number
        {
            return _limit_distance;
        }

        public function set limit_distance(value:Number):void
        {
            _limit_distance = value;
        }

        public function get speed():Number
        {
            return _speed;
        }

        public function set speed(value:Number):void
        {
            _speed = value;
        }

        public function get direction():Number
        {
            return _direction;
        }

        public function set direction(value:Number):void
        {
            _direction = value;
        }
    }
}
