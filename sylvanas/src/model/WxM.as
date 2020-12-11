package model
{

    public class WxM
    {
        private static var _instance:WxM;
        private var _isShow:Boolean = true;

        public function WxM()
        {

        }

        public function get isShow():Boolean
        {
            return _isShow;
        }

        public function set isShow(isshow:Boolean):void
        {
            _isShow = isshow;
        }
        
        public static function get instance():WxM
        {
            return _instance || (_instance = new WxM());
        }

    }
}
