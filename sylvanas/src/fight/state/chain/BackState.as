package fight.state.chain
{
    import fight.FightChain;
    import fight.zuma.Ball;

    import manager.GameConst;

    import struct.fsm.State;

    public class BackState extends State
    {

        private static var _instance:BackState;

        private var totalDistance:Number = 400

        public function BackState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
            var chain:FightChain = owner as FightChain
        }

        public function pullBack(chain:FightChain):void
        {
            var tailBall:Ball = chain.getTailBall()
            if (tailBall)
            {
                var distance:Number = -200 * GameConst.fixed_update_time
                chain.backDistance = chain.backDistance + Math.abs(distance)
                tailBall.pull(distance)
            }
        }

        override public function execute(owner:Object):void
        {
            super.execute(owner);
            var chain:FightChain = owner as FightChain
            if (chain.backDistance >= totalDistance)
            {
                chain.fsm.changeState(NormalBornState.instance)
            } else
            {
                pullBack(chain)
                chain.update(GameConst.fixed_update_time)
            }
        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
            var chain:FightChain = owner as FightChain
            chain.backDistance = 0
        }

        public static function get instance():BackState
        {
            return _instance || (_instance = new BackState());
        }

    }
}
