package fight.zuma
{
    import conf.cfg_goods;

    import fight.*;

    import conf.cfg_goods;
    import conf.cfg_path;
    import conf.cfg_scene;

    import enums.LanchType;

    import laya.display.Sprite;
    import laya.events.Event;
    import laya.maths.Point;
    import laya.ui.Image;
    import laya.utils.Ease;
    import laya.utils.Handler;
    import laya.utils.Tween;

    import model.LoginM;
    import model.UserInfoM;

    public class FireGun extends FightBase
    {
        private var _ani:Image;
        private var _fireBallRoot:Sprite;
        private var _anchorX:Number = 0.5;
        private var _anchorY:Number = 0.5;
        private var _with:Number;
        private var _hight:Number;
        private var _scale:Number;

        //曲线中地图位置
        private var _bornPos:Point;
        private var _endPos:Point;
        private var _bronScreenPos:Point;
        private var _endScreenPos:Point;
        private var _curPos:Point;
        private var _curScreenPos:Point;


        private var _drawDrection:GunRay;

        public static var _activeBallQueue:Array;


        public function FireGun():void
        {

        }

        public static function create(parent:Sprite, fireRoot:Sprite):FireGun
        {
            var ret:FireGun = CachePool.GetCache("FireGun", null, FireGun);
            ret.init(parent, fireRoot);
            return ret;
        }

        private function init(root:Sprite, fireRoot:Sprite):void
        {
            _fireBallRoot = fireRoot;
            _activeBallQueue = [];
            if (!_ani)
            {
                _ani = new Image("ui/fightPage/frog.png");
                root.addChild(_ani);
            }
            if (!_drawDrection)
            {
                _drawDrection = GunRay.create(fireRoot)
            }
        }

        public function updateBornPos():void
        {
            _activeBallQueue = [];
            _ani.skin = cfg_goods.instance(UserInfoM.useSkinId + "").gun_icon;
            _with = cfg_goods.instance(UserInfoM.useSkinId + "").fight_length[0];
            _hight = cfg_goods.instance(UserInfoM.useSkinId + "").fight_length[1];
            _scale = 0.5;
            _ani.width = _with * _scale;
            _ani.height = _hight * _scale;
            _ani.anchorX = _anchorX;
            _ani.anchorY = _anchorY;
            _bornPos = ZumaMap.instance.firePoint;
            _endPos = ZumaMap.instance.firePointTwo;
            _bronScreenPos = CoordGm.instance.zumaTopoDesToScr(_bornPos);
            _endScreenPos = CoordGm.instance.zumaTopoDesToScr(_endPos);
            _curPos = new Point(_bornPos.x, _bornPos.y);
            _curScreenPos = new Point(_bronScreenPos.x, _bronScreenPos.y);
            _ani.pos(_curScreenPos.x, _curScreenPos.y)
            _ani.rotation = CoordGm.instance.getGunInitRotation();
            _drawDrection.updateBornPos(_curScreenPos);
            _ani.visible = true;
        }

        public function screenResize():void
        {
            if (_curPos)
            {
                _curScreenPos = CoordGm.instance.zumaTopoDesToScr(_curPos);
                _ani.pos(_curScreenPos.x, _curScreenPos.y);
                _drawDrection.point = _curScreenPos;
            }
        }

        //枪口朝向
        public function onFireGunRotation(mousePoint:Point, len:Number):void
        {
            var rota:Number = CoordGm.instance.getGunRotation(mousePoint);
            if (ZumaMap.instance.fireLanchDrect != LanchType.NOFIXATION)
            {
                _curScreenPos = CoordGm.instance.getMovePoint(_ani, len);
                _curPos = CoordGm.instance.zumaTopoScrToDes(_curScreenPos);
                _ani.pos(_curScreenPos.x, _curScreenPos.y);
            }
            _ani.rotation = rota - 90;
            _drawDrection.updatecColliRect(rota, len);
        }

        public function jumpOtherPoint(isStatrPos:Boolean):void
        {
            ZumaManager.instance.ballIsJump = true;
            _drawDrection.isShowAni(false);
            if (isStatrPos == true && _curPos.x == _bornPos.x && _curPos.y == _bornPos.y)
            {
                ZumaManager.instance.ballIsJump = false;
                return;
            } else if (isStatrPos == false && _curPos.x == _endPos.x && _curPos.y == _endPos.y)
            {
                ZumaManager.instance.ballIsJump = false;
                return;
            }
            _bronScreenPos = CoordGm.instance.zumaTopoDesToScr(_bornPos);
            _endScreenPos = CoordGm.instance.zumaTopoDesToScr(_endPos);
            Tween.to(_ani, {
                x: ((_bronScreenPos.x + _endScreenPos.x) / 2),
                y: ((_bronScreenPos.y + _endScreenPos.y) / 2),
                scaleX: 1.5,
                scaleY: 1.5
            }, 500, Ease.bounceOut, Handler.create(this, endComplete, [isStatrPos]));

        }

        private function endComplete(isStatrPos:Boolean):void
        {
            var resultPos:Point;
            _bronScreenPos = CoordGm.instance.zumaTopoDesToScr(_bornPos);
            _endScreenPos = CoordGm.instance.zumaTopoDesToScr(_endPos);
            if (isStatrPos == true)
            {
                _curPos.x = _bornPos.x;
                _curPos.y = _bornPos.y;
                resultPos = _bronScreenPos;
            } else
            {
                _curPos.x = _endPos.x;
                _curPos.y = _endPos.y;
                resultPos = _endScreenPos;
            }
            Tween.to(_ani, {
                x: resultPos.x,
                y: resultPos.y,
                scaleX: 1,
                scaleY: 1
            }, 500, Ease.bounceOut, Handler.create(this, function ()
            {
                screenResize();
                _drawDrection.isShowAni(true);
            }));
            ZumaManager.instance.ballIsJump = false;
        }

        public function get curDesignPos():Point
        {
            return _curPos;
        }

        //发射
        public function onFire(type:Number, mousePoint:Point):void
        {
            var fireBall:FireBall = FireBall.create(_fireBallRoot, type);
            fireBall.initLanch(mousePoint);
            _activeBallQueue.push(fireBall);
        }

        override public function update(delta:Number):void
        {
            var i:Number = _activeBallQueue.length;
            while (i-- > 0)
            {
                var fire:FireBall = _activeBallQueue[i];
                fire.updateRotation(delta);
                fire.updatePosition(delta);
                if (fire.isOutOfBounds())
                {
                    _activeBallQueue.splice(i, 1);
                    onBomb(fire);
                }
            }
            _drawDrection.update(delta);
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
            _isValid = false;
            _ani.visible = false;
            CachePool.Cache("FireGun", null, this);
        }

        public function getActiveFireList():Array
        {
            return _activeBallQueue;
        }

        public function get ani():Sprite
        {
            return _ani;
        }

        public function get bronScreenPos():Point
        {
            return _bronScreenPos;
        }

        public function get endScreenPos():Point
        {
            return _endScreenPos;
        }
    }
}