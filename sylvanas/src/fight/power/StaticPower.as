package fight.power
{
    import fight.zuma.Ball;
    import fight.FightChain;

    public class StaticPower extends PowerBase
    {

        private var _fastDistance:Number
        private var _normalSpeed:Number = 50
        private var _fastTime:Number = 2
        private var _fastSpeed:Number = 500

        public function StaticPower(chain:FightChain, ball:Ball, normalSpeed:Number,
                                    fastDistance:Number, fastSpeed:Number)
        {
            super(ball, chain);
            this._normalSpeed = normalSpeed
            this._fastDistance = fastDistance
            this._fastSpeed = fastSpeed

            _fastTime = _fastDistance / _fastSpeed
        }

        public function isFastTime():Boolean
        {
            return totalTime <= _fastTime
        }

        public function nowSpeed():Number
        {
            if (totalTime >= _fastTime)
            {
                return _normalSpeed
            } else
            {
                return _fastSpeed
            }
        }

        override public function nextStep(delta:Number):Number
        {
            return nowSpeed() * delta
        }


        override public function push(delta:Number):void
        {
            totalTime = totalTime + delta
            var tailBall:Ball = chain.getTailBall()
            if (tailBall)
            {
                tailBall.pushForward(nextStep(delta))
            }
        }

        override public function destory():void
        {

        }
    }
}
