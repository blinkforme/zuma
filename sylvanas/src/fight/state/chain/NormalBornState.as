package fight.state.chain
{
    import fight.FightChain;

    import manager.GameConst;

    import struct.fsm.State;

    public class NormalBornState extends State
    {

        private static var _instance:NormalBornState;

        public function NormalBornState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
            var chain:FightChain = owner as FightChain


        }


        override public function execute(owner:Object):void
        {
            super.execute(owner);
            var chain:FightChain = owner as FightChain

            chain.checkBornBall()
            chain.static_power.push(GameConst.fixed_update_time)

            chain.update(GameConst.fixed_update_time)
        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
            var chain:FightChain = owner as FightChain

        }

        public static function get instance():NormalBornState
        {
            return _instance || (_instance = new NormalBornState());
        }

    }
}
