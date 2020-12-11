package fight.zuma
{
    import fight.*;
    import enums.LanchType;

    import laya.display.Sprite;
    import laya.maths.Point;

    import manager.GameTools;

    public class GunRay extends FightBase
    {
        private var _ani:Sprite;

        private var _width:Number = 50;
        private var _height:Number = 720;

        private var _bornPos:Point;

        private var _lastPoint:Point;
        private var _headPointA:Point;
        private var _headPointB:Point;

        private var _originPos:Point;
        private var _drectPos:Point;

        private var _allScreenPos:Point;//一个承载全局屏幕坐标的Point


        public function GunRay():void
        {

        }

        public static function create(parent:Sprite):GunRay
        {
            var ret:GunRay = CachePool.GetCache("GunRay", null, GunRay);
            ret.init(parent);
            return ret;
        }

        private function init(root:Sprite):void
        {
            if (!_ani)
            {
                _ani = new Sprite();
                root.addChild(_ani);
            }
            _ani.visible = true;
            _width = 50;
            _height = 720;
        }

        public function updateBornPos(point:Point):void
        {
            _height = 720;
            _originPos = new Point(0, 0);
            _drectPos = new Point(0, 0);
            _bornPos = ZumaMap.instance.firePoint;
            _width = _width * CoordGm.instance.minScale;
            _height = _height * CoordGm.instance.minScale;
            _ani.rotation = CoordGm.instance.getGunInitRotation();
            _ani.pos(point.x, point.y);
            _lastPoint = new Point(0, _height);
            _headPointA = new Point(point.x - _width / 2, point.y);
            _headPointB = new Point(point.x + _width / 2, point.y);
            _allScreenPos = CoordGm.instance.zumaAllDesToScr(_bornPos);
            _originPos.x = _allScreenPos.x;
            _originPos.y = _allScreenPos.y;
            _allScreenPos = CoordGm.instance.zumaAllDesToScr(_lastPoint);
            _drectPos.x = _allScreenPos.x;
            _drectPos.y = _allScreenPos.y;
            _isValid = true;
            //            drawTriangle();
        }

        public function isShowAni(boo:Boolean):void
        {
            _ani.visible = boo;
        }

        public function updatecColliRect(rota:Number, len:Number):void
        {
            _ani.rotation = rota - 90;
            var deX:Number = _height * GameTools.CalCosBySheet(rota);
            var deY:Number = _height * GameTools.CalSinBySheet(rota);
            var _curPos:Point = new Point(_bornPos.x + deX, _bornPos.y + deY);
            _allScreenPos = CoordGm.instance.zumaAllDesToScr(_curPos);
            _drectPos.x = _allScreenPos.x;
            _drectPos.y = _allScreenPos.y;
            if (ZumaMap.instance.fireLanchDrect != LanchType.NOFIXATION)
            {
                var resultPos:Point = CoordGm.instance.getMovePoint(_ani, len);
                _ani.pos(resultPos.x, resultPos.y);
            }
        }

        override public function update(delta:Number):void
        {
            hitAllBall();
        }

        public function hitAllBall():void
        {
            var isHitBall:Boolean = false;
            var ballArr:Array = Ball._ballArr;
            var isHitBallArr:Array = [];
            var drectionRote:Number
            var rote:Number;
            var ball:Ball;
            if (ballArr && ballArr.length > 0)
            {
                drectionRote = GameTools.CalLineAngle(_originPos, _drectPos);
                for (var i:int = 0; i < ballArr.length; i++)
                {
                    ball = ballArr[i] as Ball;
                    if (ball.isValid() == true)
                    {
                        rote = GameTools.CalLineAngle(_originPos, ball.allSceneScrennPos);
                        if (Math.abs(rote - drectionRote) <= 40)
                        {
                            isHitBall = true;
                            isHitBallArr.push(ball);
                        }
                    }
                }
            }
            //当碰到球
            if (isHitBall == true && isHitBallArr.length > 0)
            {
                //计算最近的球
                isCrashBall(isHitBallArr)
            } else//当没有碰到球 直射到墙壁长度
            {
                _height = 720;
            }
            _lastPoint = new Point(0, _height);
            drawTriangle();
        }

        private function isCrashBall(ballArr:Array):void
        {
            var smallNum:Number = 0;
            var len:Number = 0;
            var ball:Ball;
            for (var i:int = 0; i < ballArr.length; i++)
            {
                ball = ballArr[i];
                len = GameTools.CalPointLen(_originPos, ball.allSceneScrennPos);
                if (len < smallNum || smallNum == 0)
                {
                    smallNum = len;
                }
            }
            _height = smallNum - Ball.RADIUS;
        }

        public function set point(point:Point):void
        {
            _ani.pos(point.x, point.y);
            _bornPos = ZumaManager.instance.fireGun.curDesignPos;
            _allScreenPos = CoordGm.instance.zumaAllDesToScr(_bornPos);
            _originPos.x = _allScreenPos.x;
        }

        public function set rotation(value:Number):void
        {
            _ani.rotation = value;
        }

        private function drawTriangle():void
        {
            _ani.graphics.clear();
            _ani.graphics.drawPoly(0, 0, [-15, 0, 15, 0, _lastPoint.x, _lastPoint.y], "#ffff00");
        }

        public function onBomb(fire:FireBall):void
        {
            fire.destroy();
        }

        override public function isValid():Boolean
        {
            return _isValid;
        }

        override public function destroy():void
        {
            if (isValid() == false)
            {
                return
            }
            _isValid = false;
            CachePool.Cache("GunRay", null, this);
        }
    }
}