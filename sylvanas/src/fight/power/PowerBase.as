package fight.power
{
    import fight.zuma.Ball;
    import fight.FightChain;

    public class PowerBase
    {
        private var _ball:Ball
        private var _chain:FightChain;
        private var _isValid:Boolean = true;

        private var _totalTime:Number = 0

        public function PowerBase(ball:Ball, chain:FightChain)
        {
            this._ball = ball
            this._chain = chain
        }

        public function push(delta:Number):void
        {
            _totalTime += delta
        }


        public function nextStep(delta:Number):Number
        {
            return 0
        }

        public function destory():void
        {

        }


        public function get totalTime():Number
        {
            return _totalTime;
        }

        public function set totalTime(value:Number):void
        {
            _totalTime = value;
        }

        public function get ball():Ball
        {
            return _ball;
        }

        public function set ball(value:Ball):void
        {
            _ball = value;
        }


        public function get isValid():Boolean
        {
            return _isValid;
        }

        public function set isValid(value:Boolean):void
        {
            _isValid = value;
        }


        public function get chain():FightChain
        {
            return _chain;
        }

        public function set chain(value:FightChain):void
        {
            _chain = value;
        }
    }
}
