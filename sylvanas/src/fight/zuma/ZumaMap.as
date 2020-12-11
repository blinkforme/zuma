package fight.zuma
{
    import conf.cfg_background;
    import conf.cfg_goods;
    import conf.cfg_path;
    import conf.cfg_scene;

    import enums.BallDepth;
    import enums.GunMoveType;
    import enums.LanchType;

    import fight.*;

    import laya.display.Sprite;
    import laya.events.Event;
    import laya.maths.Point;
    import laya.ui.Image;

    import manager.ConfigManager;
    import manager.GameConst;
    import manager.GameTools;

    import model.UserInfoM;

    public class ZumaMap
    {
        public static var _instance:ZumaMap;
        public static var _fightMapArr:Array;
        public static var _fightChainArr:Array;
        public static var _snakeSegment:Array;
        public var _mapId:Number = 0;

        //背景底图
        private var _mapImg:Image;
        private var _mapImgWidth:Number = GameConst.zuma_with;
        private var _mapImgHeight:Number = GameConst.zuma_height;
        //轨道图
        private var _pathwayImg:Image;
        private var _pathwayImgWidth:Number = 720;
        private var _pathwayImgHeight:Number = 720;
        //旋涡图
        private var _endShowImgArr:Array;
        private var _endShowPointArr:Array;
        //入口图
        private var _comeShowImgArr:Array;
        private var _comeShowPointArr:Array;
        //洞口图
        private var _holeShowImgArr:Array;

        private var _gameOver:Boolean = false;

        private var _firePoint:Point = new Point();
        private var _firePointTwo:Point = new Point();
        //底座
        private var _onePedestal:Image;
        private var _twoPedestal:Image;

        private var _with:Number;
        private var _hight:Number;
        private var _scale:Number;
        private var _slidePedestal:Image;

        private var _gunMoveType:Number = GunMoveType.NOMOVE;//1.不移动2.滑动3.跳动
        private var _fireLanchDrect:Number = LanchType.NOFIXATION;

        private var _distanceToGun:Number = 0;

        //曲线路径信息
        public static var _mapArray:Array = []; //曲线路径信息
        public static var _lineArray:Array = [];

        private var _ballType:Number = 0;//珠子种类

        public static var _roadblockArr:Array;


        public static function get instance():ZumaMap
        {
            return _instance || (_instance = new ZumaMap());
        }


        public function ZumaMap()
        {

        }

        public function initMap(parent:Sprite, roadBlockRoot:Sprite, sceneid:Number):void
        {
            if (!_mapImg)
            {
                _mapImg = new Image();
                parent.addChild(_mapImg);
            }
            if (!_pathwayImg)
            {
                _pathwayImg = new Image();
                parent.addChild(_pathwayImg);
            }
            _comeShowImgArr = []
            _holeShowImgArr = []
            _endShowImgArr = [];
            _endShowPointArr = []
            _comeShowPointArr = [];
            _roadblockArr = [];
            _with = 270;
            _hight = 270;
            _scale = 0.5;
            _mapId = sceneid;
            var sceneData:cfg_scene = cfg_scene.instance(_mapId + "");
            var pathData:cfg_path = cfg_path.instance(sceneData.path_id + "");
            var backgroundData:cfg_background = cfg_background.instance(sceneData.scene_id + "");
            var fightChain:FightChain;
            _fightChainArr = [];
            for (var i:int = 0; i < _fightMapArr.length; i++)
            {
                _mapArray = _fightMapArr[i];
                fightChain = new FightChain(sceneData);
                _fightChainArr.push(fightChain)
                var comeShowImg:Image = new Image();
                roadBlockRoot.addChild(comeShowImg);
                var holeShowImg:Image = new Image();
                parent.addChild(holeShowImg);
                var endShowImg:Image = new Image("ui/fightPage/img_rk_02.png");
                parent.addChild(endShowImg);
                endShowImg.anchorX = 0.5;
                endShowImg.anchorY = 0.5;
                comeShowImg.anchorX = 0.5;
                comeShowImg.anchorY = 0.5;
                holeShowImg.anchorX = 0.5;
                holeShowImg.anchorY = 0.5;
                endShowImg.scale(0.8, 0.8);
                comeShowImg.zOrder = BallDepth.UP;
                endShowImg.skin = cfg_goods.instance(backgroundData.vortex_id + "").icon;
                comeShowImg.skin = cfg_goods.instance(backgroundData.come_id + "").icon;
                holeShowImg.skin = cfg_goods.instance(backgroundData.hole_id + "").icon;
                comeShowImg.width = cfg_goods.instance(backgroundData.come_id + "").fight_length[0];
                comeShowImg.height = cfg_goods.instance(backgroundData.come_id + "").fight_length[1];
                holeShowImg.width = cfg_goods.instance(backgroundData.hole_id + "").fight_length[0];
                holeShowImg.height = cfg_goods.instance(backgroundData.hole_id + "").fight_length[1];
                _endShowPointArr.push(new Point(pathData.endShowPoint[i * 2], pathData.endShowPoint[i * 2 + 1]));
                var oneChain:FightChain = ZumaMap._fightChainArr[i];
                var _linePosition:LinePosition = new LinePosition(oneChain.line.headPoint, 0, oneChain.line);
                _linePosition.move(2);
                comeShowImg.rotation = GameTools.CalLineAngle(new Point(oneChain.line.startVector().x, oneChain.line.startVector().y), new Point(0, 0)) + 90;
                holeShowImg.rotation = GameTools.CalLineAngle(new Point(-oneChain.line.endVector().x, -oneChain.line.endVector().y), new Point(0, 0));
                _comeShowPointArr.push(_linePosition.point);
                _comeShowImgArr.push(comeShowImg);
                _holeShowImgArr.push(holeShowImg);
                _endShowImgArr.push(endShowImg)
            }
            _gameOver = false;
            _mapImg.skin = cfg_goods.instance(backgroundData.bg_id + "").icon;
            _ballType = sceneData.colorType;
            initGunMove(pathData, parent);
            initRoadBlock(pathData, roadBlockRoot);
            _distanceToGun = cfg_goods.instance(UserInfoM.useSkinId + "").distanceToGun;
            _pathwayImg.skin = pathData.path_bg + "";
            _mapImg.anchorX = 0.5;
            CoordGm.instance.bornWall = pathData.bornWall;
            screenResize();
        }

        public function gameStop():void
        {
            _gameOver = true;
            for (var i:int = 0; i < _comeShowImgArr.length; i++)
            {
                _comeShowImgArr[i].visible = false;
                _comeShowImgArr[i].destroy();
                _holeShowImgArr[i].visible = false;
                _holeShowImgArr[i].destroy();
                _endShowImgArr[i].visible = false;
                _endShowImgArr[i].destroy();
            }
        }

        private function initRoadBlock(pathData:cfg_path, roadBlockRoot:Sprite):void
        {
            if (!pathData.roadblock_ids || pathData.roadblock_ids.length <= 0)
            {
                return;
            }
            var oneRoadBload:RoadBlock;
            for (var i:int = 0; i < pathData.roadblock_ids.length; i++)
            {
                oneRoadBload = RoadBlock.creat(roadBlockRoot, pathData, i);
                _roadblockArr.push(oneRoadBload);
            }
        }

        public function linePointOfDistance(distance:Number):Point
        {
            var oneChain:FightChain = ZumaMap._fightChainArr[0];
            var _linePosition:LinePosition = new LinePosition(oneChain.line.headPoint, 0, oneChain.line);
            _linePosition.move(distance);
            return _linePosition.point;
        }

        private function initGunMove(pathData:cfg_path, parent:Sprite):void
        {
            _gunMoveType = pathData.gunMoveType;
            _fireLanchDrect = pathData.fire_orientation;
            trace("类型", _gunMoveType, _fireLanchDrect);
            if (!_onePedestal)
            {
                _onePedestal = new Image();
                parent.addChild(_onePedestal);
            }
            if (!_twoPedestal)
            {
                _twoPedestal = new Image();
                parent.addChild(_twoPedestal);
            }
            if (!_slidePedestal)
            {
                _slidePedestal = new Image("ui/fightPage/hang1.png");
                parent.addChild(_slidePedestal);
            }
            _onePedestal.skin = cfg_goods.instance("" + UserInfoM.useSkinId).base_icon;
            _twoPedestal.skin = cfg_goods.instance("" + UserInfoM.useSkinId).base_icon;
            _onePedestal.name = "Pedestal";
            _twoPedestal.name = "Pedestal";
            _onePedestal.hitTestPrior = true;
            _twoPedestal.hitTestPrior = true;
            _onePedestal.offAll(Event.CLICK);
            _twoPedestal.offAll(Event.CLICK);
            _onePedestal.visible = false;
            _twoPedestal.visible = false;
            _slidePedestal.visible = false;
            _onePedestal.anchorX = 0.5;
            _onePedestal.anchorY = 0.5;
            _twoPedestal.anchorX = 0.5;
            _twoPedestal.anchorY = 0.5;
            _slidePedestal.sizeGrid = "34,59,32,32";
            _onePedestal.width = _with * _scale;
            _onePedestal.height = _hight * _scale;
            _twoPedestal.width = _with * _scale;
            _twoPedestal.height = _hight * _scale;
            _firePoint.x = pathData.fire_point[0];
            _firePoint.y = pathData.fire_point[1];
            if (_gunMoveType == GunMoveType.NOMOVE)
            {
                _onePedestal.visible = true;
            } else if (_gunMoveType == GunMoveType.HSLIDE || _gunMoveType == GunMoveType.VSLIDE)
            {
                _firePointTwo.x = pathData.fire_point[2];
                _firePointTwo.y = pathData.fire_point[3];
                _slidePedestal.visible = true;
                if (_gunMoveType == GunMoveType.HSLIDE)
                {
                    _slidePedestal.height = _with * _scale;
                    _slidePedestal.anchorY = 0.5;
                    _slidePedestal.pivotX = 100;
                } else
                {
                    _slidePedestal.anchorX = 0.5;
                    _slidePedestal.pivotY = 100;
                    _slidePedestal.width = _with * _scale;
                }
            } else if (_gunMoveType == GunMoveType.JUMP)
            {
                _firePointTwo.x = pathData.fire_point[2];
                _firePointTwo.y = pathData.fire_point[3];
                _onePedestal.visible = true;
                _twoPedestal.visible = true;
            }
            _onePedestal.hitTestPrior = true;
            _twoPedestal.hitTestPrior = true;
        }

        public function update(delta):void
        {
            if (_gameOver == true)
            {
                return;
            }
            for (var i:int = 0; i < _endShowImgArr.length; i++)
            {
                var one:Image = _endShowImgArr[i] as Image;
                one.rotation += (delta * 30);
            }
        }

        public function screenResize():void
        {
            if (!_mapImg || !_pathwayImg || !_pathwayImg)
            {
                return;
            }
            if (_mapImg && _pathwayImg)
            {
                _mapImg.width = _mapImgWidth * CoordGm.instance.maxScale;
                _mapImg.height = _mapImgHeight * CoordGm.instance.maxScale;
                _mapImg.x = Laya.stage.width / 2;
            }
            if (_pathwayImg)
            {
                _pathwayImg.width = _pathwayImgWidth * CoordGm.instance.minScale;
                _pathwayImg.height = _pathwayImgHeight * CoordGm.instance.minScale;
                _pathwayImg.x = CoordGm.instance.zumaMapXY().x;
                _pathwayImg.y = CoordGm.instance.zumaMapXY().y;
            }
            if (_gameOver == false)
            {
                for (var i:int = 0; i < _endShowImgArr.length; i++)
                {
                    if (_endShowImgArr[i])
                    {
                        var endScre:Point = CoordGm.instance.zumaTopoDesToScr(_endShowPointArr[i]);
                        var comeScre:Point = CoordGm.instance.zumaTopoDesToScr(_comeShowPointArr[i]);
                        _comeShowImgArr[i].pos(comeScre.x, comeScre.y);
                        _endShowImgArr[i].pos(endScre.x, endScre.y);
                        _endShowImgArr[i].scale(0.8 * CoordGm.instance.minScale, 0.8 * CoordGm.instance.minScale);
                        _holeShowImgArr[i].pos(endScre.x, endScre.y);
                    }
                }
            }
            var screenOne:Point;
            var screenTwo:Point;
            if (_gunMoveType == GunMoveType.NOMOVE)
            {
                screenOne = CoordGm.instance.zumaTopoDesToScr(_firePoint);
                _onePedestal.pos(screenOne.x, screenOne.y);
            } else if (_gunMoveType == GunMoveType.HSLIDE || _gunMoveType == GunMoveType.VSLIDE)
            {
                screenOne = CoordGm.instance.zumaTopoDesToScr(_firePoint);
                screenTwo = CoordGm.instance.zumaTopoDesToScr(_firePointTwo);
                _slidePedestal.pos(screenOne.x, screenOne.y);
                if (_gunMoveType == GunMoveType.HSLIDE)
                {
                    _slidePedestal.width = GameTools.CalPointLen(screenOne, screenTwo) + 200 * CoordGm.instance.minScale;
                } else
                {
                    _slidePedestal.height = GameTools.CalPointLen(screenOne, screenTwo) + 200 * CoordGm.instance.minScale;
                }
            } else if (_gunMoveType == GunMoveType.JUMP)
            {
                screenOne = CoordGm.instance.zumaTopoDesToScr(_firePoint);
                screenTwo = CoordGm.instance.zumaTopoDesToScr(_firePointTwo);
                _onePedestal.pos(screenOne.x, screenOne.y);
                _twoPedestal.pos(screenTwo.x, screenTwo.y);
            }
            if (_roadblockArr && _roadblockArr.length > 0)
            {
                for (var i:int = 0; i < _roadblockArr.length; i++)
                {
                    (_roadblockArr[i] as RoadBlock).screenResize();
                }
            }
        }


        public function initFightChain(sceneId:Number):void
        {
            var pathId:Number = cfg_scene.instance(sceneId + "").path_id;
            _fightMapArr = [];
            var lineArray:Array = ConfigManager.getConfValue("cfg_path", pathId, "path_one") as Array;
            var mapArray:Array = lineDataToMapData(lineArray);
            _fightMapArr.push(mapArray);
            lineArray = ConfigManager.getConfValue("cfg_path", pathId, "path_two") as Array;
            if (lineArray && lineArray.length > 0)
            {
                mapArray = lineDataToMapData(lineArray);
                _fightMapArr.push(mapArray);
            }
            trace("重新加载连", _fightMapArr);
        }

        public function lineDataToMapData(lineArr:Array):Array
        {
            var mapArr:Array = [];
            for (var i:int = 0; i < lineArr.length; i += 2)
            {
                mapArr.push({
                    x: lineArr[i],
                    y: lineArr[i + 1]
                })
            }
            return mapArr;
        }

        public function failurePoint():Point
        {
            return _mapArray[_mapArray.length - 1];
        }

        public function get firePoint():Point
        {
            return _firePoint;
        }

        public function get distanceToGun():Number
        {
            return _distanceToGun;
        }

        public function get ballType():Number
        {
            return _ballType;
        }

        public function get pathwayImg():Image
        {
            return _pathwayImg;
        }

        public function get fireLanchDrect():Number
        {
            return _fireLanchDrect;
        }

        public function get firePointTwo():Point
        {
            return _firePointTwo;
        }

        public function get gunMoveType():Number
        {
            return _gunMoveType;
        }

        public function get onePedestal():Image
        {
            return _onePedestal;
        }

        public function get twoPedestal():Image
        {
            return _twoPedestal;
        }

        public function get mapImg():Image
        {
            return _mapImg;
        }
    }
}