package
{
    import control.LoginC;
    import control.WxC;

    import laya.display.Stage;
    import laya.events.MouseManager;
    import laya.media.SoundManager;
    import laya.net.Loader;
    import laya.net.ResourceVersion;
    import laya.net.URL;
    import laya.utils.Browser;
    import laya.utils.Handler;
    import laya.utils.Stat;
    import laya.utils.Utils;
    import laya.wx.mini.MiniAdpter;

    import manager.ApiManager;
    import manager.ConfigManager;
    import manager.GameConst;
    import manager.GameInit;
    import manager.ScreenAdaptManager;
    import manager.UiManager;

    import model.LoginInfoM;

    import view.load.Load;
    import view.load.LoadPageView;
    import view.login.Login;
    import view.mainPage.MainPage;
    import view.fightPage.FightPage;
    import view.goldTip.GoldTip;
    import view.account.Account;
    import view.setting.Setting;
    import view.friendsRanking.FriendsRanking;
    import view.shop.Shop;
    import view.award.Award;
    import view.insideNotice.InsideNotice;

    public class Main
    {
        public function Main()
        {

            //根据IDE设置初始化引擎
            console.log("WxC.isInMiniGame():" + WxC.isInMiniGame())
            if (WxC.isInMiniGame())
            {
                MiniAdpter.init(true);
                WxC.wx_show_share_menu();
                //                WxC.wx_onShow();

                //                WxC.wx_on_window_resize();
                //                WxC.wx_onHide();
                //                WxC.wx_get_system_info();
                //                WxC.wx_start_accelerometer();
                //                WxC.wx_on_accelerometer_change();
                //                WxC.wx_on_window_error();
                //                WxC.wx_netWork();
                //                WxC.wx_screen_state();
                //                WxC.instance.initAdVideo();
            }
            Laya.init(GameConfig.width, GameConfig.height, Laya["WebGL"]);


            Laya.stage.bgColor = "#95c0b5";
            if (Browser.onPC)
            {
                Laya.stage.alignV = Stage.ALIGN_MIDDLE;
                Laya.stage.alignH = Stage.ALIGN_CENTER;

                Laya.stage.scaleMode = Stage.SCALE_SHOWALL;
                Laya.stage.screenMode = Stage.SCREEN_NONE;
            } else
            {
                Laya.stage.alignV = "middle";
                Laya.stage.alignH = "center";
                Laya.stage.scaleMode = Stage.SCALE_EXACTFIT;
                Laya.stage.screenMode = Stage.SCREEN_VERTICAL;
            }

            ScreenAdaptManager.instance.init();
            GameInit.instance.init();
            initENV();

            //打开调试面板（IDE设置调试模式，或者url地址增加debug=true参数，均可打开调试面板）
            if (GameConfig.debug || Utils.getQueryString("debug") == "true") Laya.enableDebugPanel();
            if (GameConfig.physicsDebug && Laya["PhysicsDebugDraw"]) Laya["PhysicsDebugDraw"].enable();
            if (GameConfig.stat) Stat.show();
            Laya.alertGlobalError = true;

            MouseManager.multiTouchEnabled = true;
            SoundManager.setMusicVolume(GameConst.default_bgm_music);
            SoundManager.setSoundVolume(GameConst.default_sound);
            SoundManager.autoReleaseSound = false;
            checkVersion();

        }

        public function loadConfig():void
        {
            Laya.loader.load([{
                url: ConfigManager.getConfigPath(),
                type: Loader.JSON
            }], Handler.create(this, initConfig));
        }

        private function initENV():void
        {

            if (WxC.isInMiniGame())
            {
                ENV.env = ENV.PROD_ENV;
                ENV.isLoginView = false;
                if (ENV.env == ENV.PROD_ENV && ENV.isLoginView == false)
                {
                    URL.basePath = ENV.MiniGameRemoteUrlBase;
                }
            } else
            {
                ENV.env = ENV.TEST_ENV;
                ENV.isLoginView = true;
            }

            LoginInfoM.instance.api_domain = ENV.API_DOMAIN;
        }

        public function checkVersion():void
        {
            if (!ENV.isLoginView || WxC.isInMiniGame())
            {
                ApiManager.instance.checkVersion(ENV.VERSION, Handler.create(this, onCheckVersionFinish), Handler.create(this, null));
            } else
            {
                loadConfig();
            }
        }

        public function onCheckVersionFinish(data:*):void
        {
            var data:Object = data["data"]
            if (data["version"])
            {
                ConfigManager.configPath = data["config_manifest"];
                ResourceVersion.enable(data["manifest"], Handler.create(this, this.loadConfig), ResourceVersion.FILENAME_VERSION);
            } else
            {
                if (ENV.env == ENV.PROD_ENV && LoginInfoM.instance.api_domain != ENV.MINI_API_URL)
                {
                    LoginInfoM.instance.api_domain = ENV.MINI_API_URL;
                    ApiManager.instance.checkVersion(ENV.VERSION, Handler.create(this, onCheckVersionFinish), Handler.create(this, null))
                } else
                {
                    console.log("微信小游戏ENV.env，需要为PROD_ENV,且isLoginView，为false")
                }
            }
        }

        private function initConfig():void
        {
            ConfigManager.init(onVersionLoaded);
        }

        private function onVersionLoaded():void
        {
            if (!ENV.isLoginView || WxC.isInMiniGame())
            {
                //激活大小图映射，加载小图的时候，如果发现小图在大图合集里面，则优先加载大图合集，而不是小图
                //            AtlasInfoManger.enable("fileconfig.json");
                UiManager.instance.loadView("Load");
            } else
            {
                LoginC.instance.beginLogin();
            }
        }

    }
}