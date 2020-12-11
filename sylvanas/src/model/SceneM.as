package model
{

    import control.WxShareC;

    import manager.ApiManager;
    import manager.ConfigManager;
    import manager.GameEventDispatch;
    import manager.GameEvent;

    public class SceneM
    {

        private static var _instance:SceneM;
        public static var sceneInfo:Object; // 存储在本地缓存中的关卡信息

        public static var isSuccess = false;
        // sceneInfo = {
        //     "sceneId": 1, // 当前关卡ID
        //     "sceneList": [
        //         {
        //             "sceneId": 1, // 关卡ID
        //             "pass": 2, // 0：未解锁，1：通关，2：解锁未通关
        //             "star": 0 // 星星数0/1/2/3
        //         }
        //     ]
        // }

        public static function get instance():SceneM
        {
            return _instance || (_instance = new SceneM());
        }

        // 初始化关卡信息并存储到微信缓存中
        public function initWxSceneInfo(scene):void
        {
            sceneInfo = WxShareC.getStorageSync('sceneInfo');
            var sceneList:Array = [];
            if (!sceneInfo)
            {
                // 根据关卡信息初始化sceneInfo
                for (var i:int = 0; i < scene.length; i++)
                {
                    var sceneMsg:Object = {
                        sceneId: scene[i].id,
                        pass: scene[i].id == 1 ? 2 : 0,
                        star: 0
                    }
                    sceneList.push(sceneMsg);
                }
                sceneInfo = {
                    "sceneId": 1,
                    "sceneList": sceneList
                }
            } else if (sceneInfo && sceneInfo.sceneList)
            {
                // 关卡信息已存在，判断是否增加新关卡
                for (var j:int = 0; j < scene.length; j++)
                {
                    if (!sceneInfo.sceneList[j] || scene[j].id != sceneInfo.sceneList[j].sceneId)
                    {
                        sceneInfo.sceneList[j] = {
                            "sceneId": scene[j].id,
                            "pass": scene[j].id == 1 ? 2 : 0,
                            "star": 0
                        }
                    }
                }
            }

            WxShareC.setStorageSync('sceneInfo', sceneInfo);
        }

        // 存储关卡信息
        public function setSceneInfo(sceneInfo):void
        {
            var url:String = '/backup_data';
            var params:String = 'token=' + LoginInfoM.instance.token + '&data=' + sceneInfo;
            ApiManager.instance.base_request(url, params, 'POST', setSceneInfoComplete);
        }

        // 存储关卡信息成功
        public function setSceneInfoComplete(res):void
        {
            if (res.code == 'success')
            {
                isSuccess = true;
            }
            else
            {
                isSuccess = false;
            }
        }

        // 获取关卡信息
        public function getSceneInfo():void
        {
            var url:String = '/user_data?token=' + LoginInfoM.instance.token;
            var params:String = 'token=' + LoginInfoM.instance.token;
            ApiManager.instance.base_request(url, params, 'GET', getSceneInfoComplete);
        }

        // 获取关卡信息成功
        public function getSceneInfoComplete(res):void
        {
            if (res.code == 'success')
            {
                var sceneList:Array = [];
                var scene:Array = ConfigManager.items('cfg_scene');
                if (!res.data.user_data)
                {
                    // 根据关卡信息初始化sceneInfo
                    for (var i:int = 0; i < scene.length; i++)
                    {
                        var sceneMsg:Object = {
                            sceneId: scene[i].id,
                            pass: scene[i].id == 1 ? 2 : 0,
                            star: 0
                        }
                        sceneList.push(sceneMsg);
                    }
                    sceneInfo = {
                        "sceneId": 1,
                        "sceneList": sceneList
                    }
                } else
                {
                    sceneInfo = {
                        "sceneId": res.data.user_data.sceneId,
                        "sceneList": res.data.user_data.sceneList
                    };
                    // 关卡信息已存在，判断是否增加新关卡
                    for (var j:int = 0; j < scene.length; j++)
                    {
                        if (!sceneInfo.sceneList[j] || scene[j].id != sceneInfo.sceneList[j].sceneId)
                        {
                            sceneInfo.sceneList[j] = {
                                "sceneId": scene[j].id,
                                "pass": scene[j].id == 1 ? 2 : 0,
                                "star": 0
                            }
                        }
                    }
                }
                SceneM.instance.setSceneInfo(JSON.stringify(sceneInfo));
            }
        }

        public function initScensInMainPage():void
        {
            if (isSuccess)
            {
                GameEventDispatch.instance.event(GameEvent.InitScene);
            }

        }
    }
}