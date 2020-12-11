package fight
{
    import fight.zuma.Ball;

    import laya.maths.Point;

    public class BallExplode
    {
        private var _balls:Array
        private var _extraBalls:Array

        private var _explodePoint:Point

        private var _status:Number = BallExplodeStatus.Exploding

        public function BallExplode(balls:Array)
        {
            _balls = balls
            _extraBalls = []
        }

        public function check():void
        {
            checkEndBalls()
        }


        public function startExplode():void
        {
            for (var i:Number = 0; i < _balls.length; i++)
            {
                var ball:Ball = _balls[i];
                ball.startExplode()
            }
        }

        public function remove():void
        {

        }

        public function checkEndBalls():void
        {
            for (var i = 0; i < balls.length; i++)
            {
                var ball:Ball = balls[i];
                if (!ball.isExploding)
                {
                    ball.destroy()
                }
            }

        }

        public function destory():void
        {
            for (var i = 0; i < balls.length; i++)
            {
                var ball:Ball = balls[i];
                ball.destroy()
            }

        }

        public function isExplodeEnd():Boolean
        {
            for (var i:Number = 0; i < _balls.length; i++)
            {
                var ball:Ball = _balls[i];
                if (ball.isExploding)
                {
                    return false
                }
            }

            return true
        }

        public function get extraBalls():Array
        {
            return _extraBalls;
        }

        public function set extraBalls(value:Array):void
        {
            _extraBalls = value;
        }

        public function get balls():Array
        {
            return _balls;
        }

        public function set balls(value:Array):void
        {
            _balls = value;
        }


        public function get explodePoint():Point
        {
            return _explodePoint;
        }

        public function set explodePoint(value:Point):void
        {
            _explodePoint = value;
        }


        public function get status():Number
        {
            return _status;
        }

        public function set status(value:Number):void
        {
            _status = value;
        }
    }
}
