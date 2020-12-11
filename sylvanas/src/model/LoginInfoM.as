package model
{
    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;

    public class LoginInfoM
    {
        public var code:Number;
        public var name:String;
        public var token:String;
        public var uid:Number;


        public var server_domain:String = "";
        public var server_name:String = "";
        public var mini_server_domain:String = "";
        public var mini_server_name:String = "";
        public var api_domain:String = "";
        public var api_domain_protocal:String = "https"
        public var user_status:String = "";
        public var is_new:Number;

        public var loginFinish:Boolean = false
        //是否使用登录框登录
        public var isLoginView:Boolean = true

        //游戏状态位操作:1:主界面使用骨骼 2:炮使用骨骼 4:鱼场使用俯视视角
        public var game_status:Number = 3;

        //是否是游客
        public var is_visitor:Boolean = false;

        public var is_sync_info:Number = 0;

        //道具赠送限制vip等级
        public var send_vip_limit:Number

        private var _shopRate:Number;

        public var mainPageShow:Boolean = false;//主界面是否加载过

        private static var _instance:LoginInfoM;
        public var platform:String = "";
        public var provider_id:String = ""

        public function LoginInfoM()
        {
            _shopRate = 1;
        }

        public static function get instance():LoginInfoM
        {
            return _instance || (_instance = new LoginInfoM());
        }

        public function setShopRate(rate:Number):void
        {
            _shopRate = rate;
        }

        public function getShopRate():Number
        {
            return _shopRate;
        }
        public function fromAndroid():Boolean
        {
            return fromGuangfan()
        }

        public function getVipSendLimit():Number
        {
            return send_vip_limit;
        }
        public function fromGuangfan():Boolean
        {
            return platform && platform == GameConst.platform_android_guangfan;
        }


    }
}
