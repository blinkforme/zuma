package model
{
    import manager.GameEvent;
    import manager.GameEventDispatch;

    public class AccountM
    {
        private static var _instance:AccountM;

        private var _acoountType:Number = -1;
        private var _acoountData:Number = -1;

        private var _shareGoBack:Number = 0;

        public function AccountM()
        {

        }

        public static function get instance():AccountM
        {
            return _instance || (_instance = new AccountM());
        }

        public function goBack():void
        {
            GameEventDispatch.instance.event(GameEvent.GoOnGameOneTimes);
        }

        public function get acoountType():Number
        {
            return _acoountType;
        }

        public function set acoountType(value:Number):void
        {
            _acoountType = value;
        }

        public function get acoountData():Number
        {
            return _acoountData;
        }

        public function set acoountData(value:Number):void
        {
            _acoountData = value;
        }

        public function get shareGoBack():Number
        {
            return _shareGoBack;
        }

        public function set shareGoBack(value:Number):void
        {
            _shareGoBack = value;
        }
    }
}
