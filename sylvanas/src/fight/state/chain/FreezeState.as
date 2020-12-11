package fight.state.chain
{
    import fight.FightChain;

    import manager.GameConst;

    import struct.fsm.State;

    public class FreezeState extends State
    {

        private static var _instance:FreezeState;

        private var freezeTime:Number = 2

        public function FreezeState()
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
            chain.update(GameConst.fixed_update_time)
            chain.freezeTime = chain.freezeTime + GameConst.fixed_update_time
            if (chain.freezeTime >= freezeTime)
            {
                chain.fsm.changeState(NormalBornState.instance)
            }
        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
            var chain:FightChain = owner as FightChain
            chain.freezeTime = 0
        }

        public static function get instance():FreezeState
        {
            return _instance || (_instance = new FreezeState());
        }

    }
}
