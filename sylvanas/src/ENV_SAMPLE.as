package
{
    import control.WxC;

    public class ENV_SAMPLE
    {
        public static function get API_DOMAIN()
        {
            if (env == TEST_ENV)
            {
                console.log("stage")
                return "api-sylvanas.qzygxt.com";//TEST
            } else if (env == STAGE_ENV)
            {
                console.log("stage")
                return "api-sylvanas.qzygxt.com";//stage
            } else if (env == PROD_ENV)
            {
                console.log("prod")
                if (WxC.isInMiniGame())
                {
                    return MINI_GAME_API_URL; //prod
                }
                else
                {
                    return MINI_GAME_API_URL; //prod
                }
            }
        }

        //【上线检查】是否是登录框登录(即是否是本地登录)
        public static var isLoginView:Boolean = false;

        //判断环境
        //【上线检查】当env等于TEST_ENV时，使用TEST_ENV_WS_URL连接游戏服务器
        public static var env:String = PROD_ENV;//test|stage|prod//TEST_ENV

        public static const TEST_ENV:String = "test"
        public static const STAGE_ENV:String = "stage"
        public static const PROD_ENV:String = "prod"

        public static const buriedUrl:String = "https://collector.12h5.com"


        //-------------------------------------微信小游戏--------------------------

        //【上线检查】
        public static const VERSION:String = "v20190328_1"

        //【上线检查】
        public static const MiniGameRemoteUrlBase:String = "https://cdn-byh5.jjhgame.com/zuma_wx_resource/zuma_wx_mini6/";

        //stage
        public static const STAGE_API_DOMAIN:String = "api-sylvanas.qzygxt.com"

        //提审
        public static const MINI_API_URL:String = "tzm-api.jjhgame.com"

        //线上
        public static const MINI_GAME_API_URL:String = "zm-api.jjhgame.com"

        //-----------------------------游戏配置-------------------------------
        public static const IsFrameAnimation = false;//球是否是帧动画

    }
}