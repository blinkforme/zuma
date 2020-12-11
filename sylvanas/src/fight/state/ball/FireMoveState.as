package fight.state.ball
{
    import struct.fsm.State;

    public class FireMoveState extends State
    {
        private static var _instance:FireMoveState;

        public function FireMoveState()
        {
        }


        override public function enter(owner:Object):void
        {
            super.enter(owner);
        }

        override public function execute(owner:Object):void
        {
            super.execute(owner);
        }

        override public function exit(owner:Object):void
        {
            super.exit(owner);
        }

        public static function get instance():FireMoveState
        {
            return _instance || (_instance = new FireMoveState());
        }

    }
}
