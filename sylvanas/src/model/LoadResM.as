package model
{
    import conf.cfg_path;
    import conf.cfg_scene;

    import laya.net.Loader;

    import manager.ConfigManager;


    //仅用于描述不同场景的资源列表
    //其他逻辑请勿添加
    public class LoadResM
    {
        private static var _instance:LoadResM;

        private var _firstSceneArr:Array;//第一个场景

        private var _firstSceneSpineArr:Array;

        private var _res2dArr:Array = null;
        private var _mainRes:Array;
        private var _mainSpineArr:Array;

        private var _commonSceneArr:Array = null
        private var _commonSceneSpineArr:Array = null;

        private var _normalScenePrePlayAni:Array;

        public function LoadResM()
        {
        }


        public static function get instance():LoadResM
        {
            return _instance || (_instance = new LoadResM());
        }


        //进入场景的所需的骨骼动画
        public function get mainSpineArr():Array
        {
            if (_firstSceneSpineArr)
            {
                return _firstSceneSpineArr;
            }
            _mainSpineArr = new Array();


            return _mainSpineArr;
        }

        public function get mainRes():Array
        {
            if (_mainRes)
            {
                return _mainRes;
            }
            var up:String = "res/atlas/ui/";
            _mainRes = new Array();
            _mainRes.push({url: up + "common_ex.atlas", type: Loader.ATLAS});
            _mainRes.push({url: up + "common.atlas", type: Loader.ATLAS});
            _mainRes.push({url: "res/atlas/font.atlas", type: Loader.ATLAS});
            _mainRes.push({url: up + "mainPage.atlas", type: Loader.ATLAS});//205
            _mainRes.push({url: up + "load.atlas", type: Loader.ATLAS});//205
            _mainRes.push({url: up + "upgrade.atlas", type: Loader.ATLAS});
            _mainRes.push({url: up + "setting.atlas", type: Loader.ATLAS});
            _mainRes.push({url: up + "login.atlas", type: Loader.ATLAS});
            _mainRes.push({url: "ui/mainPage/img_di.png", type: Loader.IMAGE});
            return _mainRes;
        }

        public function get getFishRes():Array
        {

            return get2dRes;


        }

        public function get get2dRes():Array
        {
            if (_res2dArr)
            {
                return _res2dArr;
            }

            _res2dArr = [];
            var ap:String = "res/atlas/ani/";
            _res2dArr.push({url: ap + "puzzle.atlas", type: Loader.ATLAS});
            return _res2dArr;
        }


        private var _bgStr:String;

        //场景公共资源
        public function commonSceneArr():Array
        {
            if (_commonSceneArr)
            {
                return _commonSceneArr;
            }
            _commonSceneArr = [];
            _commonSceneArr.push({url: "res/atlas/ui/fightPage.atlas", type: Loader.ATLAS});
            if(ENV.IsFrameAnimation==true)
            {
                _commonSceneArr.push({url: "res/atlas/ani/coin.atlas", type: Loader.ATLAS});
                _commonSceneArr.push({url: "res/atlas/ani/blue.atlas", type: Loader.ATLAS});
                _commonSceneArr.push({url: "res/atlas/ani/green.atlas", type: Loader.ATLAS});
                _commonSceneArr.push({url: "res/atlas/ani/purple.atlas", type: Loader.ATLAS});
                _commonSceneArr.push({url: "res/atlas/ani/red.atlas", type: Loader.ATLAS});
                _commonSceneArr.push({url: "res/atlas/ani/white.atlas", type: Loader.ATLAS});
                _commonSceneArr.push({url: "res/atlas/ani/yellow.atlas", type: Loader.ATLAS});
            }
            var pathId:Number = cfg_scene.instance(LoginM.instance.sceneId + "").path_id;
            _bgStr = cfg_path.instance(pathId + "").path_bg;
            _commonSceneArr.push({url: _bgStr, type: Loader.IMAGE});
            return _commonSceneArr;
        }

        //场景公共骨骼
        public function commonSceneSpineArr():Array
        {
            if (_commonSceneSpineArr)
            {
                return _commonSceneSpineArr;
            }
            _commonSceneSpineArr = [];

            return _commonSceneSpineArr;
        }

        //第一个场景的资源
        public function get firstSceneArr():Array
        {
            if (_firstSceneArr)
            {
                return _firstSceneArr;
            }
            _firstSceneArr = commonSceneArr();
            _firstSceneSpineArr = commonSceneSpineArr();

            return _firstSceneArr;
        }


        //第一个场景要解析的骨骼动画资源
        public function get firstSceneSpineArr():Array
        {
            return _firstSceneSpineArr;
        }

        public function get normalScenePrePlayAni():Array
        {
            if (_normalScenePrePlayAni)
            {
                return _normalScenePrePlayAni;
            }
            _normalScenePrePlayAni = [
                //                {aniName: "baozha", playName: 0, aniType: 1},
            ]
            return _normalScenePrePlayAni;
        }
    }
}
