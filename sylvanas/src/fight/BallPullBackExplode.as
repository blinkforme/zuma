package fight
{
    import fight.power.PullBackPower;

    public class BallPullBackExplode extends BallExplode
    {
        private var _power:PullBackPower

        public function BallPullBackExplode(balls:Array, power:PullBackPower)
        {
            _power = power
            super(balls)
        }


        public function get power():PullBackPower
        {
            return _power;
        }

        public function set power(value:PullBackPower):void
        {
            _power = value;
        }
    }
}
