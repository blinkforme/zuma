package control
{

    import conf.cfg_share;

    import enums.ShowType;

    import laya.resource.HTMLCanvas;
    import laya.utils.Browser;
    import laya.utils.Handler;

    import manager.ApiManager;
    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.UiManager;
    import manager.WebSocketManager;

    import model.LoginInfoM;
    import model.UserInfoM;
    import model.UserInfoM;
    import model.UserInfoM;
    import model.WxM;

    public class WxC
    {

        private static var _instance:WxC;


        public static function get instance():WxC
        {
            return _instance || (_instance = new WxC());
        }

        public function WxC()
        {
            //            initAdVideo()
            //            initAdBanner()

            // GameEventDispatch.instance.on(GameEvent.GoldChange, this, setStorageSync);
        }

        public static var wxminiLoginCount:Number = 0;
        public static var wxminiCode:String;
        public static var wxminiName:String = "";
        public static var wxminiAvatar:String = "";
        public static var accessToken:String;
        public static var server_domain:String = "";
        public static var server_name:String = "";
        public static var mini_server_domain:String = "";
        public static var mini_server_name:String = "";
        public static var user_status:String = "";
        public static var client_platform:String = "";
        public static var res_version:String = "";
        public static var isError:Boolean = false;
        public static var onAppShare:Boolean = false;
        public static var shareId:String;
        public static var uID:Number = -1;
        public static var payment_amount:Number = 0;
        public static var isRequest:Boolean = false;
        //        public static var game_version:String = "vjjh_18091901";
        //        public static var game_version:String = "vjjh_18112201";
        //        public static var game_version:String = "vjjh_18122001";
        public static var game_version:String = "gf_20190305_1";
        public static var userInfoBtn;

        public static var author:Number = 1//1--有权限，2--没权限

        public var videoAd1;

        public var adUnitId = "adunit-031e940c617a38c8"
        public var isLoaded = false;

        public var bannerAd;
        public var bannerAdUitId = "adunit-f9d1a25a078f30ba"

        public static var wxSDKVersion:String = ""
        private var winInfo:Object = {}


        public static function compareVersion(v1, v2)
        {
            v1 = (v1 || "").split('.')
            v2 = (v2 || "").split('.')
            const len = Math.max(v1.length, v2.length)

            while (v1.length < len)
            {
                v1.push('0')
            }
            while (v2.length < len)
            {
                v2.push('0')
            }

            for (var i = 0; i < len; i++)
            {
                const num1 = parseInt(v1[i])
                const num2 = parseInt(v2[i])

                if (num1 > num2)
                {
                    return 1
                } else if (num1 < num2)
                {
                    return -1
                }
            }

            return 0
        }


        public function initAdBanner():void
        {
            if (isInMiniGame() && WxC.compareVersion(WxC.wxSDKVersion, GameConst.wxSDKVersion) >= 0)
            {

                bannerAd = __JS__("wx").createBannerAd({
                    adUnitId: bannerAdUitId,
                    style: {
                        left: 220,
                        top: 270,
                        width: 300
                    }
                })
                AdM.instance.bannerHeight = 87
                bannerAd.onError(onBannerADError);
                bannerAd.onResize(onBannerResize);
                bannerAd.onLoad(onBannerLoaded);
            }
        }

        public function getWinInfo()
        {
            if (isInMiniGame())
            {
                if (winInfo && winInfo.windowHeight < winInfo.windowWidth)
                {
                    return winInfo
                } else
                {
                    return __JS__("wx").getSystemInfoSync()
                }
            }
            return null
        }

        public function resetBannerStyle():void
        {
            if (isInMiniGame() && bannerAd)
            {
                var win = getWinInfo()
                //                trace("resetBannerStyle11", win)
                if (win && win.windowHeight < win.windowWidth)
                {
                    bannerAd.style.left = (win.windowWidth - 300) / 2
                    bannerAd.style.top = win.windowHeight - AdM.instance.bannerHeight
                }
                //                trace("resetBannerStyle22",bannerAd.style.left,bannerAd.style.top)
            }

        }

        //播放广告
        public function hideBannerAD():void
        {

            if (isInMiniGame() && bannerAd)
            {
                bannerAd.hide()
                bannerAd.offError(onBannerADError)
                bannerAd.offResize(onBannerResize)
                bannerAd.offLoad(onBannerLoaded)
                bannerAd.destroy()
                initAdBanner()
            }
        }

        //播放广告
        public function showBannerAD():void
        {

            if (isInMiniGame())
            {
                //                trace("showBannerAD11")
                //                trace("bannerAd", bannerAd)
                resetBannerStyle()

                if (bannerAd)
                {
                    bannerAd.show().catch(catchShowBannerError)
                }
            } else
            {
                if (ENV.isLoginView)
                {
                    adReward()
                }
            }
        }

        //重新拉去并播放
        public function catchShowBannerError():void
        {
            //            trace("catchShowBannerError")
        }

        public function onBannerLoaded():void
        {
            console.log('banner加载完成');
        }

        private function onBannerResize(res):void
        {

            AdM.instance.bannerHeight = res.height

        }

        //拉取banner广告失败
        public function onBannerADError(err):void
        {
            trace("onBannerADError", err)


        }


        public function initAdVideo():void
        {
            if (isInMiniGame() && WxC.compareVersion(WxC.wxSDKVersion, GameConst.wxSDKVersion) >= 0)
            {
                if (!videoAd1)
                {
                    videoAd1 = __JS__("wx").createRewardedVideoAd({adUnitId: adUnitId})
                    videoAd1.onError(onVideoADError);
                    videoAd1.onClose(onCloseAD);
                    videoAd1.onLoad(onLoaded);
                }
            }
        }

        public function onLoaded():void
        {
            isLoaded = true
            console.log('视频加载完成');
        }

        public function onCloseAD(res):void
        {
            console.log("onCloseAD", res)
            console.log("res.isEnded", res.isEnded)
            if (res === undefined || res.isEnded)
            {
                WebSocketManager.instance.send(19030, {})
                console.log("激励视频完整播放后关闭")
            } else
            {
                console.log("激励视频中途被关闭")
            }
            WxC.instance.loadVideoAD()
        }

        //拉取广告或者播放视频失败
        public function onVideoADError(err):void
        {
            console.log("onVideoADError", err)
            var errCode = err.errCode
            var errMsg = err.errMsg
            if (errCode != 0)
            {
                //            GameEventDispatch.instance.event(GameEvent.MsgTipContent, errMsg);

                WxC.instance.loadVideoAD()
                WxC.instance.showVideoAD()
            }
        }

        //播放广告
        public function showVideoAD():void
        {

            if (isInMiniGame() && videoAd1)
            {
                videoAd1.show().catch(catchShowError)
            } else
            {
                if (ENV.isLoginView)
                {
                    adReward()
                }
            }
        }

        public function adReward():void
        {
            WebSocketManager.instance.send(19030, {})
        }

        //播放视频时没有成功拉取到广告物料
        //重新拉去并播放
        public function catchShowError():void
        {
            console.log("catchShowError", catchShowError)
            WxC.instance.loadVideoAD()
            WxC.instance.showVideoAD()
        }

        public function loadVideoAD():void
        {
            isLoaded = false
            if (videoAd1)
                videoAd1.load()
        }

        public static function isHideShop():Boolean
        {
            //            return true
            return Browser.onIOS && isInMiniGame()
        }

        public static function isInMiniGame():Boolean
        {
            var wx = __JS__("window.wx")
            if (wx)
            {
                return true
            } else
            {
                return false
            }
        }

        public function MiniStartObj():Object
        {
            return __JS__("wx.getLaunchOptionsSync()")
        }

        public static function isMiniLayout():Boolean
        {
            return WxC.isInMiniGame()
        }

        public static function onHideCallback():void
        {
            isRequest = false;
            if ((isError || !WebSocketManager.instance.isConnect()) && !onAppShare)
            {
                exitGame();

            }

        }

        public static function onShowCallback(res:Object):void
        {
            wxUpdate();
            if (isInMiniGame())
            {
                var c:Object = res.query;
                var userId:Number = c["key1"]
                uID = userId;
                if (userId != null)
                {
                    var acesn:String = WxC.accessToken;
                    if (acesn != null)
                    {
                        isRequest = true;
                        ApiManager.instance.getShareInfo(acesn, userId, Handler.create(WxC, share), null);
                    } else
                    {

                    }
                }

            }
        }


        public static function wxRequest():void
        {
            if (isInMiniGame())
            {
                if (isRequest == false && uID != null)
                {
                    ApiManager.instance.getShareInfo(WxC.accessToken, uID, Handler.create(WxC, share), null);
                }
            }
        }

        public static function getLaunchArgs():void
        {
            if (isInMiniGame())
            {
                var obj:Object = __JS__("wx").getLaunchOptionsSync();
                return obj.query;
            }
            return
        }

        public static function getLaunchChannel():String
        {
            if (isInMiniGame())
            {
                var obj:Object = __JS__("wx").getLaunchOptionsSync();
                if (obj && obj.query && obj.query["ch"])
                {
                    return obj.query["ch"]
                }
                return "000";
            }
            return "000";
        }

        public static function share(msg:Object):void
        {
            trace(JSON.stringify(msg) + "分享获取的结果");

        }

        public static function wx_onHide():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").onHide(onHideCallback);
            }
        }

        public static function wx_onShow():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").onShow(onShowCallback);
            }
        }

        public static function wx_netWork():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").onNetworkStatusChange(onNetCallback);
            }
        }

        //        public static function setStorageSync(key:String, re:Object):void
        //        {
        //            if (isInMiniGame())
        //            {
        //                __JS__("wx").setStorageSync(key, {data: re});
        //            }
        //        }

        public static function onNetCallback(isConnected:Boolean, networkType:String):void
        {
            trace("网络状态");
        }

        public static function authorize_success():void
        {
            trace("authorize_success");
            author = 1
            get_user_info();//获取用户信息
        }

        public static function authorize_fail():void
        {
            trace("authorize_fail");
            author = 2
            get_user_info();//获取用户信息
        }

        public static function authorize_complete():void
        {
            trace("authorize_complete");
        }

        public static function authorize():void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.scope = "scope.userInfo";//snsapi_userinfo snsapi_base
                params.success = authorize_success;
                params.fail = authorize_fail;
                params.complete = authorize_complete;
                __JS__("wx").authorize(params);
            }
        }


        /**
         * @author liuwenlin 2018-6-26
         * 检测checkSession状态{success:sessionkey未过期,fail:sessionkey过期,需重新login}
         */
        public static function checkSession():void
        {
            var wx = __JS__("wx")

            wx.login({
                success: function (res)
                {
                    if (res.errMsg == "login:ok")
                    {
                        wxminiCode = res.code;
                        get_user_info();//获取用户信息
                    }
                },
                fail: function (err)
                {
                }
            });
        }

        public static function exitGame():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").exitMiniProgram();
            }
        }

        public static function get_user_info_success(data:*):void
        {
            author = 1
            wxminiName = data.userInfo.nickName;
            wxminiAvatar = data.userInfo.avatarUrl;
            __JS__("wx").setStorageSync("wxminiName", wxminiName);
            __JS__("wx").setStorageSync("wxminiAvatar", wxminiAvatar);
            __JS__("wx").setStorageSync("wxminiCode", wxminiCode);
            //            GameEventDispatch.instance.event(GameEvent.WxMiniLoginComplete, null);
            //            if (WxC.userInfoBtn)
            //            {
            //                WxC.userInfoBtn.hide();
            //            }
        }

        public static function get_user_info_fail():void
        {
            GameEventDispatch.instance.event(GameEvent.WxMiniLoginComplete, null);
        }

        public static function get_user_info_complete(data:*):void
        {
            author = 2
            UiManager.instance.loadView("InsideNotice", null, ShowType.SMALL_TO_BIG);
        }

        public static var userInfoButton:* = null;

        public static function user_info_button_tap_callback(data:*):void
        {

        }

        public static var button

        public static function createUserInfoButton(page:String):void
        {

            if (isInMiniGame())
            {
                var win = __JS__("wx").getSystemInfoSync()
                button = __JS__("wx").createUserInfoButton({
                    type: 'text',
                    text: '',
                    style: {
                        left: win.windowWidth / 4,
                        top: win.windowHeight / 2,
                        width: win.windowWidth / 2,
                        height: win.windowHeight / 2,
                        lineHeight: win.windowHeight / 2,
                        backgroundColor: '#00ff0000',
                        color: '#ffffff',
                        textAlign: 'center',
                    }
                })
                button.onTap(function (res)
                {
                    UiManager.instance.closePanel(page, false);
                    if (res.errMsg == "getUserInfo:ok")
                    {
                        if (res.userInfo)
                        {
                            WxC.get_user_info_success(res)
                            UserInfoM.instance.name = res.userInfo.nickName;
                            UserInfoM.instance.avatar = res.userInfo.avatarUrl;
                        }
                        author = 1
                    }
                    GameEventDispatch.instance.event(GameEvent.WxMiniLoginComplete, null);
                    WxC.button.destroy()

                })
            }
        }


        public static function get_user_info():void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.success = get_user_info_success;
                params.fail = get_user_info_fail;
                params.complete = get_user_info_complete;
                __JS__("wx").getUserInfo(params);
            }
        }


        public static function login_success(data):void
        {
            if (data.errMsg == "login:ok")
            {
                wxminiCode = data.code;
            }
            authorize()
        }

        public static function getNetWrokState():void
        {
            var parms:Object = new Object();
            parms.success = networkSucess;


        }

        public static function networkSucess():void
        {

        }


        public static function url():String
        {
            var tempFilePath:* = __JS__("wx").createCanvas().toTempFilePathSync({
                x: 10,
                y: 10,
                width: 200,
                height: 150,
                destWidth: 400,
                destHeight: 300
            })
            return tempFilePath;
        }

        public static function shareUrl():*
        {
            var htmlC:HTMLCanvas = Laya.stage.drawToCanvas(Laya.stage.width, Laya.stage.height, 0, 0);
            __JS__("wx").setStorageSync("htmlCanvas", htmlC);
            var url:* = __JS__("wx").wx.getStorageSync("htmlCanvas");
            return url;
        }


        public static function wx_share():void
        {
            if (isInMiniGame())
            {
                var shareCotent:cfg_share = WxM.instance.shareInfo;
                var uid:String = LoginInfoM.instance.uid + "";

                var a:String = "key1=" + uid + "&key2=" + 34
                var params:Object = new Object();
                params.title = shareCotent.txt
                params.query = a;
                params.imageUrl = shareCotent.image;

                params.success = shareSucess;
                params.fail = sharefail;
                params.complete = complete;
                __JS__("wx").shareAppMessage(params);
            }
        }

        public static function shareImg():*
        {
            var htmlC:HTMLCanvas = Laya.stage.drawToCanvas(Laya.stage.width, Laya.stage.height, 0, 0);
            var canvans:* = htmlC.getCanvas();
            return canvans.toDataURL("image/png");

        }

        //竞技场分享
        public static function area_share():void
        {
            if (isInMiniGame())
            {
                var shareCotent:cfg_share = WxM.instance.shareInfo;
                var params:Object = new Object();
                params.title = shareCotent.txt;
                params.imageUrl = shareCotent.image;
                params.success = areaShareSucess;
                params.fail = areaShareFail;
                params.complete = areaShareComplete;
                __JS__("wx").shareAppMessage(params);
            }
        }


        public static function areaShareComplete():void
        {

        }

        public static function areaShareFail():void
        {

        }

        public static function areaShareSucess():void
        {
            GameEventDispatch.instance.event(GameEvent.AreaShareSucess);
        }


        public static function shareInfo(tick:String):void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.shareTicket = tick;
                params.sucess = getInfoSucess;
                params.fail = getInfoFail;
                params.complete = getInfoComplete
            }
        }

        public static function getInfoComplete():void
        {

        }

        public static function getInfoSucess():void
        {

        }

        public static function getInfoFail():void
        {

        }

        public static function shareSucess(res:Object):void
        {
            trace("shareTickets:" + res.shareTickets)
        }

        public static function sharefail():void
        {

        }

        public static function complete():void
        {

        }

        public static function login_fail():void
        {
            GameEventDispatch.instance.event(GameEvent.WxMiniLoginComplete, null);
        }

        public static function login_complete():void
        {
            trace("login_complete");
        }


        public static function wx_login():void
        {
            var params:Object = new Object();
            params.success = login_success;
            params.fail = login_fail;
            params.complete = login_complete;
            __JS__("wx").login(params);
        }

        public static function wx_rankdata(key:String, value:*):void
        {
            var kvDataList = new Array();
            kvDataList.push({
                key: key,
                value: JSON.stringify(value)
            });
            trace("CCC", kvDataList)
            var param:Object = new Object();
            param.KVDataList = kvDataList;
            param.success = setrank_success;
            param.fail = setrank_fail;
            __JS__("wx").setUserCloudStorage(param)
        }

        public static function setrank_success():void
        {
            trace("排行榜set成功")
        }

        public static function setrank_fail():void
        {
            trace("排行榜set失败")
        }

        public static function getFriendStorage(re:String):void
        {
            var param:Object = new Object();
            param.keyList = re;
            param.success = getrank_success;
            param.fail = getrank_fail;
            __JS__("wx").getFriendCloudStorage(param);
        }

        public static function getrank_success(res:*):void
        {

            trace("get数据成功", res)
        }

        public static function getrank_fail(err:*):void
        {
            trace("get数据失败", err)
        }

        public static function refreshlogin_success(data):void
        {
            if (data.errMsg == "login:ok")
            {
                wxminiCode = data.code;
                //通知服务器刷新
            }
            get_user_info();
        }

        public static function refreshlogin_fail():void
        {
        }

        public static function refreshlogin_complete():void
        {
        }


        public static function requestPayment_fail(data):void
        {
        }

        public static function requestPayment_complete(data):void
        {
        }


        public static var model:String = "none";

        public static function get_system_info_success(data:*):void
        {
            client_platform = data.platform;
            model = data.model;
            wxSDKVersion = data.SDKVersion
        }

        public static function get_system_info_fail(data:*):void
        {
        }

        public static function get_system_info_complete(data:*):void
        {
        }


        public static function wx_get_system_info():void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.success = get_system_info_success;
                params.fail = get_system_info_fail;
                params.complete = get_system_info_complete;
                __JS__("wx").getSystemInfo(params);
            }
        }

        public static function on_window_resize_callback(data:*):void
        {
        }

        public static function wx_on_window_resize():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").onWindowResize(on_window_resize_callback);
            }
        }


        public static function wx_on_window_error():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").onError(onerror);
            }
        }

        public static function onerror():void
        {
            isError = true;
        }


        public static function start_compass_success():void
        {
            trace("start_compass_success");
        }

        public static function start_compass_fail():void
        {
            trace("start_compass_fail");
        }

        public static function start_compass_complete():void
        {
            trace("start_compass_complete");
        }

        public static function wx_start_compass():void
        {
            if (isInMiniGame())
            {
                //				var params:Object = new Object();
                //				params.success = start_compass_success;
                //				params.fail = start_compass_fail;
                //				params.complete = start_compass_complete;
                //				__JS__("wx").startCompass(params);
            }
        }

        public static var compassTraceTick:int = 0;

        public static function on_compass_change_callback(direction:*):void
        {
            compassTraceTick = compassTraceTick + 1;
            if (compassTraceTick > 10)
            {
                compassTraceTick = 0;
            }
        }

        public static function wx_on_compass_change():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").onCompassChange(on_compass_change_callback);
            }
        }

        public static function start_accelerometer_success():void
        {
        }

        public static function start_accelerometer_fail():void
        {
        }

        public static function start_accelerometer_complete():void
        {
        }

        public static function wx_start_accelerometer():void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.success = start_compass_success;
                params.fail = start_compass_fail;
                params.complete = start_compass_complete;
                __JS__("wx").startAccelerometer(params);
            }
        }

        public static var accelerometerTraceTick:int = 0;
        public static var accelerData:* = null;

        public static function on_accelerometer_change_callback(data:*):void
        {
            //			accelerometerTraceTick = accelerometerTraceTick + 1;
            //			if(accelerometerTraceTick > 10)
            //			{
            //				trace(data.x, data.y, data.z);
            //				compassTraceTick = 0;
            //			}
            accelerData = data;
        }

        public static function get_notch():String
        {
            if (null != accelerData)
            {
                if (accelerData.x > 0 && accelerData.y > 0 && accelerData.z < 0)
                {
                    return "right";
                }
                if (accelerData.x < 0 && accelerData.y > 0 && accelerData.z < 0)
                {
                    return "left";
                }
            }
            return "normal";
        }

        public static function wx_on_accelerometer_change():void
        {
            if (isInMiniGame())
            {
                __JS__("wx").onAccelerometerChange(on_accelerometer_change_callback);
            }
        }

        public static function save_file_list_success(data):void
        {
            trace(JSON.stringify(data));
        }

        public static function save_file_list_fail(data):void
        {

        }

        public static function save_file_list_complete(data):void
        {

        }

        public static function wx_file_manager_trace():void
        {
            if (isInMiniGame())
            {
                var fileManager:Object = __JS__("wx").getFileSystemManager();
                var params:Object = new Object();
                trace("wx_file_manager_trace start");
                trace(__JS__('wx.env.USER_DATA_PATH'));
                trace(fileManager.accessSync("spine/wannianjue/H5_wannianjue.sk"));
                //trace(MiniFileMgr.getCacheUseSize());
                params.success = save_file_list_success;
                params.fail = save_file_list_fail;
                params.complete = save_file_list_complete;
                fileManager.getSavedFileList(
                        params
                );
            }
        }


        //小游戏的版本更新
        public static function wxUpdate():void
        {
            if (isInMiniGame() && __JS__("wx").getUpdateManager)
            {
                var updateManager = __JS__("wx").getUpdateManager();
                updateManager.onCheckForUpdate(function (res)
                {
                    if (res.hasUpdate)
                    {
                        __JS__("wx").showLoading({
                            title: '升级中',
                            mask: true
                        })
                    }
                    trace("版本信息的回调:" + JSON.stringify(res));
                })
                updateManager.onUpdateReady(function ()
                {
                    __JS__("wx").hideLoading();
                    __JS__("wx").showModal({
                        title: '升级提示',
                        content: '新版本已经准备好，是否重启应用？',
                        success: function (res)
                        {
                            if (res.confirm)
                            {
                                updateManager.applyUpdate()
                            }
                        }
                    });
                })

                updateManager.onUpdateFailed(function ()
                {
                    __JS__("wx").hideLoading();
                    __JS__("wx").showModal({
                        title: '升级失败',
                        content: '新版本下载失败，请检查网络！',
                        showCancel: false
                    });
                })

            }
        }


        public function wx_showLoading():void
        {
            if (isInMiniGame())
            {

            }
        }


        public function wx_hideLoading():void
        {

        }


        public function wx_showModal():void
        {

        }


        public static function wx_screen_state():void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.keepScreenOn = true;
                __JS__("wx").setKeepScreenOn(params);
            }
        }

        public static function on_share_app_message_success():void
        {
            //onAppShare = false;
        }

        public static function on_share_app_message_fail():void
        {
            //onAppShare = false;
        }

        public static function on_share_app_message_complete():void
        {
            onAppShare = false;
        }

        public static function on_share_app_message_callback(data:*):Object
        {
            onAppShare = true;
            return {
                imageUrl: "https://cdn-byh5.jjhgame.com/goufei/head_img/fenx1.png",
                success: on_share_app_message_success,
                fail: on_share_app_message_fail,
                complete: on_share_app_message_complete
            }
        }


        public static function wx_show_share_menu():void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.withShareTicket = true;
                __JS__("wx").showShareMenu(params);
                __JS__("wx").onShareAppMessage(on_share_app_message_callback);
            }
        }

        public static function set_clipboard_data_success():void
        {
        }

        public static function set_clipboard_data_fail():void
        {
        }

        public static function wx_set_clipboard_data(content:String):void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.data = content;
                //params.success = set_clipboard_data_success;//关闭tips提示
                //params.fail = set_clipboard_data_fail;//关闭tips提示
                __JS__("wx").setClipboardData(params);
            }
        }

        public static function get_clipboard_data_success(data:*):void
        {
            GameEventDispatch.instance.event(GameEvent.WxGetClipBoard, data.data);
        }

        public static function get_clipboard_data_fail(data:*):void
        {
            GameEventDispatch.instance.event(GameEvent.WxGetClipBoard, null);
        }

        public static function wx_get_clipboard_data():void
        {
            if (isInMiniGame())
            {
                var params:Object = new Object();
                params.success = get_clipboard_data_success;
                params.fail = get_clipboard_data_fail;
                __JS__("wx").getClipboardData(params);
            }
        }

        public static function wx_launch_app():void
        {
            if (isInMiniGame())
            {

            }
        }

        public static function wxShare(htmlC:HTMLCanvas):void
        {
            if (isInMiniGame())
            {
                //var htmlC:HTMLCanvas = Laya.stage.drawToCanvas(Laya.stage.width,Laya.stage.height,0,0);
                var canvans:* = htmlC.getCanvas();
                canvans.toTempFilePath({
                            x: 10,
                            y: 10,
                            width: Laya.stage.width,
                            height: Laya.stage.height,
                            destWidth: 400,
                            destHeight: 300,
                            success: function (res)
                            {
                                __JS__("wx").shareAppMessage({
                                    imageUrl: res.tempFilePath,
                                    complete: function ()
                                    {
                                        GameEventDispatch.instance.event(GameEvent.ScreenShareComplete, null);
                                    },
                                    title: "分享"
                                })
                            }
                        }
                )
            }
        }

        /**
         * 创建组合shareImg
         */
        public static function creatShareImg():void
        {

        }

    }

}
