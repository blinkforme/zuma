package fight
{
    import enums.BallColor;
    import enums.GunMoveType;
    import enums.LanchType;

    import fight.zuma.ZumaManager;

    import fight.zuma.ZumaMap;

    import laya.display.Sprite;

    import laya.maths.Point;

    import manager.GameConst;
    import manager.GameTools;

    public class CoordGm
    {
        private static var _instance:CoordGm;

        private var _zumaWith:Number = GameConst.zuma_with;
        private var _zumaHeight:Number = GameConst.zuma_height;
        private var _warWith:Number = GameConst.war_with;
        private var _warHeight:Number = GameConst.war_height;

        private var _minScale:Number = 0;
        private var _maxScale:Number = 0;

        private var _bornWall:Number = 1;//1:上，2：右，3：下，4：左

        public static function get instance():CoordGm
        {
            return _instance || (_instance = new CoordGm());
        }

        public function CoordGm():void
        {

        }

        private var _temp:Point = new Point();

        public function zumaTopoDesToAllScr(point:Point):Point
        {
            var point:Point = new Point(point.x, point.y + Laya.stage.height * GameConst.war_percent);
            return point;
        }

        //局部设计坐标转全局屏幕坐标
        public function zumaAllDesToScr(point:Point):Point
        {
            var point:Point = zumaTopoDesToScr(point)
            point.y = point.y + Laya.stage.height * GameConst.war_percent;
            return point;
        }

        //局部设计坐标转局部屏幕坐标
        public function zumaTopoDesToScr(point:Point):Point
        {
            var point:Point = new Point(_minScale * point.x + zumaMapXY().x, _minScale * point.y + zumaMapXY().y)
            return point;
        }

        //局部屏幕坐标转局部设计坐标
        public function zumaTopoScrToDes(point:Point):Point
        {
            var point:Point = new Point((point.x - zumaMapXY().x) / _minScale, (point.y - zumaMapXY().y) / _minScale)
            return point;
        }

        public function warTopoDesToScr(point:Point):Point
        {
            var point:Point = new Point(Laya.stage.width / GameConst.design_width * point.x,
                    Laya.stage.height / GameConst.design_height * point.y)
            return point;
        }

        public function zumaMapXY():Point
        {
            switch (_bornWall)
            {
                case 1:
                    return new Point((Laya.stage.width - ZumaMap.instance.pathwayImg.width) / 2, 0);
                case 2:
                    return new Point((Laya.stage.width - ZumaMap.instance.pathwayImg.width), (Laya.stage.height * GameConst.zuma_percent - ZumaMap.instance.pathwayImg.height) / 2)
                case 3:
                    return new Point((Laya.stage.width - ZumaMap.instance.pathwayImg.width) / 2, Laya.stage.height * GameConst.zuma_percent - ZumaMap.instance.pathwayImg.height)
                case 4:
                    return new Point(0, (Laya.stage.height * GameConst.zuma_percent - ZumaMap.instance.pathwayImg.height) / 2);
            }
        }

        public function updateZumaScale():void
        {
            var scale:Number = Laya.stage.width / _zumaWith;
            if (Laya.stage.height * GameConst.zuma_percent / _zumaHeight > scale)
            {
                _maxScale = Laya.stage.height * GameConst.zuma_percent / _zumaHeight;
                _minScale = scale;
            } else
            {
                _maxScale = scale;
                _minScale = Laya.stage.height * GameConst.zuma_percent / _zumaHeight;
            }
            //            trace("min", _minScale, "max", _maxScale);
        }

        public function getBallSkinUrl(type:Number):String
        {
            var str:String;
            if (type == BallColor.PURPLE)
            {
                str = "ui/fightPage/qiu_01.png"

            } else if (type == BallColor.GREEN)
            {
                str = "ui/fightPage/qiu_02.png";

            } else if (type == BallColor.BLUE)
            {
                str = "ui/fightPage/qiu_03.png";

            } else if (type == BallColor.RED)
            {
                str = "ui/fightPage/qiu_04.png";

            } else if (type == BallColor.YELLOW)
            {
                str = "ui/fightPage/qiu_05.png";
            } else if (type == BallColor.WHITE)
            {
                str = "ui/fightPage/qiu_06.png";
            }

            return str;
        }

        public function getBallFrameAniName(type:Number):String
        {
            var str:String;
            if (type == BallColor.PURPLE)
            {
                str = "purple"

            } else if (type == BallColor.GREEN)
            {
                str = "green";

            } else if (type == BallColor.BLUE)
            {
                str = "blue";

            } else if (type == BallColor.RED)
            {
                str = "red";

            } else if (type == BallColor.YELLOW)
            {
                str = "yellow";
            } else if (type == BallColor.WHITE)
            {
                str = "white";
            }
            return str;
        }

        public function getGunRotation(mousePoint:Point):Number
        {
            var rota:Number;
            if (ZumaMap.instance.fireLanchDrect == LanchType.NOFIXATION)
            {
                var born:Point;
                born = zumaAllDesToScr(ZumaManager.instance.fireGun.curDesignPos);
                rota = GameTools.CalLineAngle(born, mousePoint);
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.UP)
            {
                rota = 270;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.RIGHT)
            {
                rota = 0;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.DOWN)
            {
                rota = 90;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.LEFT)
            {
                rota = 180;
            }
            return rota
        }

        public function getGunInitRotation():Number
        {
            if (ZumaMap.instance.fireLanchDrect == LanchType.NOFIXATION)
            {
                return 0;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.UP)
            {
                return 180;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.RIGHT)
            {
                return -90;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.DOWN)
            {
                return 0;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.LEFT)
            {
                return 90;
            }
        }

        public function getLanchMousePoint(mousePoint:Point):Point
        {
            var bornScreen:Point = zumaAllDesToScr(ZumaManager.instance.fireGun.curDesignPos);
            if (ZumaMap.instance.fireLanchDrect == LanchType.NOFIXATION)
            {
                return mousePoint;
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.UP)
            {

                return new Point(bornScreen.x, bornScreen.y - 100);
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.RIGHT)
            {
                return new Point(bornScreen.x + 100, bornScreen.y);
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.DOWN)
            {
                return new Point(bornScreen.x, bornScreen.y + 100);
            } else if (ZumaMap.instance.fireLanchDrect == LanchType.LEFT)
            {
                return new Point(bornScreen.x - 100, bornScreen.y);
            }
        }

        public function getMovePoint(obj:Sprite, len:Number):Point
        {
            var bronScreenPos:Point = zumaTopoDesToScr(ZumaMap.instance.firePoint);
            var endScreenPos:Point = zumaTopoDesToScr(ZumaMap.instance.firePointTwo);
            var resultPos:Point;
            if (ZumaMap.instance.gunMoveType == GunMoveType.HSLIDE)
            {
                resultPos = new Point(obj.x + len, obj.y);
                if (resultPos.x < bronScreenPos.x)
                {
                    resultPos.x = bronScreenPos.x;
                } else if (resultPos.x > endScreenPos.x)
                {
                    resultPos.x = endScreenPos.x;
                }
            } else if (ZumaMap.instance.gunMoveType == GunMoveType.VSLIDE)
            {
                resultPos = new Point(obj.x, obj.y + len);
                if (resultPos.y < bronScreenPos.y)
                {
                    resultPos.y = bronScreenPos.y;
                } else if (resultPos.y > endScreenPos.y)
                {
                    resultPos.y = endScreenPos.y;
                }
            } else
            {
                resultPos = new Point(obj.x, obj.y);
            }
            return resultPos;
        }

        public function get minScale():Number
        {
            return _minScale;
        }

        public function get maxScale():Number
        {
            return _maxScale;
        }

        public function set bornWall(value:Number):void
        {
            _bornWall = value;
        }
    }
}