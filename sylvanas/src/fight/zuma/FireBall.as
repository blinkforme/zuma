package fight.zuma
{
    import fight.*;
    import laya.display.Animation;
    import laya.display.Sprite;

    import laya.maths.Point;

    import laya.ui.Image;

    import laya.utils.Ease;
    import laya.utils.Handler;
    import laya.utils.Tween;

    import manager.AnimalManger;
    import manager.FishAniManager;
    import manager.GameConst;
    import manager.GameTools;

    public class FireBall extends FightBase
    {
        private var _ani:Sprite;

        private var _type:Number = -1;
        private var _with:Number = 0;
        private var _height:Number = 0;
        private var _anchorX:Number = 0.5;
        private var _anchorY:Number = 0.5;
        private var _fixLen:Number = 50;

        private var _speed:Number = 1000;
        private var _speedX:Number = 2;
        private var _speedY:Number = 2;

        private var _lanchPoint:Point;
        private var _oldDesignPos:Point;
        //曲线中地图位置
        private var _bornPos:Point;
        private var _curPos:Point;
        private var _rota:Number = 0;

        private var _screenPos:Point;

        public function FireBall():void
        {

        }

        public static function create(parent:Sprite, type:Number = null):FireBall
        {
            var ret:FireBall = CachePool.GetCache("FireBall", type + "", FireBall);
            ret.init(parent, type);
            return ret;
        }

        private function init(root:Sprite, type:Number):void
        {
            _bornPos = ZumaManager.instance.fireGun.curDesignPos;
            _type = type;
            _with = GameConst.BallWith;
            _height = GameConst.BallWith;
            if (!_ani)
            {
                //                if (ENV.IsFrameAnimation == false)
                //                {
                _ani = new Image(CoordGm.instance.getBallSkinUrl(_type));
                _ani.width = _with;
                _ani.height = _height;
                _ani.pivot(_with / 2, _with / 2);
                //                } else
                //                {
                //                    _ani = FishAniManager.instance.load(CoordGm.instance.getBallFrameAniName(_type));
                //                    _ani.scale(_with / 76, _height / 76);
                //                    _ani.pivot(38, 38);
                //                }

                root.addChild(_ani);
            }

            //            playAnimation();
            _ani.visible = true;
            _curPos = _bornPos;
            _screenPos = CoordGm.instance.zumaTopoDesToScr(_bornPos);
            _ani.pos(_screenPos.x, _screenPos.y);
            _isValid=true;
        }

        public function playAnimation():void
        {
            if (ENV.IsFrameAnimation == true)
            {
                (_ani as Animation).play(0, true);
            }
        }

        public function initLanch(mousePoint:Point):void
        {
            _oldDesignPos = CoordGm.instance.zumaAllDesToScr(_bornPos);
            _lanchPoint = CoordGm.instance.getLanchMousePoint(mousePoint);
            var len:Number = GameTools.CalPointLen(_oldDesignPos, _lanchPoint);
            var lenX:Number = _lanchPoint.x - _oldDesignPos.x;
            var lenY:Number = _lanchPoint.y - _oldDesignPos.y;
            var k:Number = _speed / len;
            _speedX = k * lenX;
            _speedY = k * lenY;
        }

        public function updatePosition(delta:Number):void
        {
            if (_lanchPoint)
            {
                _ani.x += _speedX * delta;
                _ani.y += _speedY * delta;
            }
        }

        public function onFireGunPos(mousePoint:Point, len:Number, isPrepare:Boolean = false):void
        {
            _bornPos = ZumaManager.instance.fireGun.curDesignPos;
            _rota = CoordGm.instance.getGunRotation(mousePoint);
            var distace:Number;
            if (!isPrepare)
            {
                distace = ZumaMap.instance.distanceToGun;
            } else
            {
                distace = ZumaMap.instance.distanceToGun - 50;
            }
            var deX:Number = distace * GameTools.CalCosBySheet(_rota);
            var deY:Number = distace * GameTools.CalSinBySheet(_rota);
            _curPos = new Point(_bornPos.x + deX, _bornPos.y + deY);
            _screenPos = CoordGm.instance.zumaTopoDesToScr(_curPos);
            //            var resultPos:Point = CoordGm.instance.getMovePoint(_ani, len)
            _ani.pos(_screenPos.x, _screenPos.y);
        }

        public function screenResize():void
        {
            if (_curPos)
            {
                _screenPos = CoordGm.instance.zumaTopoDesToScr(_curPos);
                _ani.pos(_screenPos.x, _screenPos.y);
            }
        }

        public function initFireBallPos(isPrepare:Boolean = false):void
        {
            _bornPos = ZumaMap.instance.firePoint;
            var distace:Number;
            if (!isPrepare)
            {
                distace = ZumaMap.instance.distanceToGun;
            } else
            {
                distace = ZumaMap.instance.distanceToGun - 50;
            }
            _rota = CoordGm.instance.getGunInitRotation() + 90;
            var deX:Number = distace * GameTools.CalCosBySheet(_rota);
            var deY:Number = distace * GameTools.CalSinBySheet(_rota);
            _curPos = new Point(_bornPos.x + deX, _bornPos.y + deY);
            _screenPos = CoordGm.instance.zumaTopoDesToScr(_curPos);
            _ani.x = _screenPos.x;
            _ani.y = _screenPos.y;
        }

        public function jumpOtherPoint(isStatrPos:Boolean, isPrepare:Boolean = false):void
        {
            var bronScreenPos:Point;
            var endScreenPos:Point;
            var distace:Number;
            if (!isPrepare)
            {
                distace = ZumaMap.instance.distanceToGun;
            } else
            {
                distace = ZumaMap.instance.distanceToGun - 50;
            }
            var deX:Number = distace * GameTools.CalCosBySheet(_rota);
            var deY:Number = distace * GameTools.CalSinBySheet(_rota);
            bronScreenPos = CoordGm.instance.zumaTopoDesToScr(new Point(ZumaMap.instance.firePoint.x + deX, ZumaMap.instance.firePoint.y + deY));
            endScreenPos = CoordGm.instance.zumaTopoDesToScr(new Point(ZumaMap.instance.firePointTwo.x + deX, ZumaMap.instance.firePointTwo.y + deY));

            if (isPrepare == true)
            {
                Tween.to(_ani, {
                    x: ((bronScreenPos.x + endScreenPos.x) / 2),
                    y: ((bronScreenPos.y + endScreenPos.y) / 2),
                    zOrder: _ani.zOrder,
                    scaleX: 0.45,
                    scaleY: 0.45
                }, 500, Ease.bounceOut, Handler.create(this, endComplete, [isStatrPos, isPrepare]));
            } else
            {
                Tween.to(_ani, {
                    x: ((bronScreenPos.x + endScreenPos.x) / 2),
                    y: ((bronScreenPos.y + endScreenPos.y) / 2),
                    zOrder: _ani.zOrder,
                    scaleX: 1.5,
                    scaleY: 1.5
                }, 500, Ease.bounceOut, Handler.create(this, endComplete, [isStatrPos, isPrepare]));
            }
        }

        private function endComplete(isStatrPos:Boolean, isPrepare:Boolean = false):void
        {
            var resultPos:Point;
            var bronScreenPos:Point;
            var endScreenPos:Point;
            var distace:Number;
            if (!isPrepare)
            {
                distace = ZumaMap.instance.distanceToGun;
            } else
            {
                distace = ZumaMap.instance.distanceToGun - 50;
            }
            var deX:Number = distace * GameTools.CalCosBySheet(_rota);
            var deY:Number = distace * GameTools.CalSinBySheet(_rota);
            bronScreenPos = CoordGm.instance.zumaTopoDesToScr(new Point(ZumaMap.instance.firePoint.x + deX, ZumaMap.instance.firePoint.y + deY));
            endScreenPos = CoordGm.instance.zumaTopoDesToScr(new Point(ZumaMap.instance.firePointTwo.x + deX, ZumaMap.instance.firePointTwo.y + deY));

            if (isStatrPos == true)
            {
                _curPos.x = ZumaMap.instance.firePoint.x;
                _curPos.y = ZumaMap.instance.firePoint.y;
                resultPos = bronScreenPos;
            } else
            {
                _curPos.x = ZumaMap.instance.firePointTwo.x;
                _curPos.y = ZumaMap.instance.firePointTwo.y;
                resultPos = endScreenPos;
            }

            if (isPrepare == true)
            {
                Tween.to(_ani, {
                    x: resultPos.x,
                    y: resultPos.y,
                    scaleX: 0.3,
                    scaleY: 0.3,
                    zOrder: _ani.zOrder
                }, 500, Ease.bounceOut);
            } else
            {
                Tween.to(_ani, {
                    x: resultPos.x,
                    y: resultPos.y,
                    scaleX: 1,
                    scaleY: 1,
                    zOrder: _ani.zOrder
                }, 500, Ease.bounceOut);
            }
            ZumaManager.instance.ballIsJump = false;
        }

        public function setScale(scale:Number):void
        {
            _ani.scale(scale * _with / 76, scale * _height / 76);
        }

        public function getDesignPoint():Point
        {
            return CoordGm.instance.zumaTopoScrToDes(new Point(_ani.x, _ani.y));
        }

        public function getScreenPoint():Point
        {
            return new Point(_ani.x, _ani.y);
        }

        public function updateRotation(delta:Number):void
        {
            _ani.rotation += delta * 100;
        }

        public function setActive(isActive:Boolean):void
        {
            _ani.visible = isActive;
        }

        public function getActive():Boolean
        {
            return _ani.visible;
        }

        public function setAniSprite(type:Number, isPrepare:Boolean = false):void
        {
            _type = type;
            //            if (ENV.IsFrameAnimation == false)
            //            {
            var sprite:Image = _ani as Image;
            sprite.skin = CoordGm.instance.getBallSkinUrl(_type);
            //            } else
            //            {
            //                _ani = null;
            //                if (!_ani)
            //                {
            //                    _ani = AnimalManger.instance.load(CoordGm.instance.getBallFrameAniName(_type));
            //                    _ani.scale(_with / 76, _height / 76);
            //                    _ani.pivot(38, 38);
            //                }
            //            }
            //            playAnimation();
        }

        public function isOutOfBounds():Boolean
        {
            if (_ani.x < -_fixLen || _ani.x > Laya.stage.width + _fixLen || _ani.y < -_fixLen || _ani.y > Laya.stage.height * GameConst.zuma_percent + _fixLen)
            {
                return true;
            }
            return false;
        }

        override public function isValid():Boolean
        {
            _isValid = true;
            if (!_ani || _ani.visible == false)
            {
                _isValid = false
            }
            return _isValid;
        }

        override public function destroy():void
        {
            if (!isValid())
            {
                return
            }
            _isValid = false;
            _ani.visible = false;
            CachePool.Cache("FireBall", _type + "", this);
        }


        public function get type():Number
        {
            return _type;
        }

        public function set type(value:Number):void
        {
            _type = value;
        }
    }
}