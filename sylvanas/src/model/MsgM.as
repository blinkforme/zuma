package model
{
    public class MsgM
    {
        private var _msgX:Number;
        private var _msgY:Number;
        private var _content:String;
        private var _isShow:Boolean;

        private static var _instance:MsgM;

        public function MsgM()
        {

        }

        public static function get instance():MsgM
        {
            return _instance || (_instance = new MsgM());
        }

        public function setContentInfo(msgConent:String):void
        {
            _content = msgConent;
            _isShow = true;

        }

        public function get msgX():Number
        {
            return _msgX;
        }

        public function get msgY():Number
        {
            return _msgY;
        }

        public function get content():String
        {
            return _content;

        }

        public function get isShow():Boolean
        {
            return _isShow
        }

        public function set isShow(isShow:Boolean):void
        {
            _isShow = isShow;
        }


    }
}
