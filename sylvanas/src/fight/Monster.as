package fight
{
    import conf.cfg_role;

    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.ui.Label;
    import laya.ui.ProgressBar;
    import laya.utils.Handler;

    import manager.ConfigManager;

    import manager.GameConst;
    import manager.SpineTemplet;

    public class Monster extends FightBase
    {
        private var _ani:Sprite;
        private var _aniType:Number = -1;
        private var _aniName:String;
        private var _monsterType = -1;
        private var _id = -1;

        private var _bloodBar:ProgressBar;
        private var _bloodWith:Number = 0;
        private var _bloodHeight:Number = 0;
        private var _bloodOffsetX:Number = 0;
        private var _bloodOffsetY:Number = 0;
        private var _fullBlood:Number = 0;
        private var _curBlood:Number = 0;

        private var _colliheight:Number = 0;
        private var _colliOffsetX:Number = 0;
        private var _colliOffsetY:Number = 0;
        private var _colliwidth:Number = 0;

        private var _initPos:Point = new Point(GameConst.war_with / 2, GameConst.war_height - 150);
        private var _bornPos:Point = new Point();
        private var _curPos:Point = new Point();
        private var _screenPos:Point = new Point();

        private var _aniActionMusic:Array = [];//出现音效 受击音效 捕获音效

        private var _aniActionInfo:Array = [];//待机 行走 死亡 战斗

        public static var _monsterArr:Array;
        private var _isActionDead:Boolean = false;

        public function Player():void
        {

        }


        public static function create(parent:Sprite, monsterType:Number, id:Number):Monster
        {
            var ret:Monster = CachePool.GetCache("Monster", null, Monster);
            ret.init(parent, monsterType, id);
            _monsterArr.push(ret);
            return ret;
        }


        private function init(root:Sprite, monsterType:Number, id:Number):void
        {
            _monsterType = monsterType;
            _id = id;
            var config:cfg_role = cfg_role.instance("" + _monsterType);
            _aniName = config.aniName;
            _aniActionMusic = [config.comeSound, config.hitSound, config.CatchSound];
            _aniActionInfo = [config.sleepAni, config.moveAni, config.deadAni, config.atkAni, config.big_atkAni];
            _aniType = ConfigManager.getConfValue("cfg_anicollision", _aniName, "aniType") as Number;
            if (!_ani)
            {
                if (_aniType == GameConst.ani_type_skeleton)
                {
                    _ani = new SpineTemplet(_aniName);
                } else if (_aniType == GameConst.ani_type_frame)
                {

                }
                root.addChild(_ani);
            }
            if (!_bloodBar)
            {
                _bloodBar = new ProgressBar("ui/common_ex/p2.png");
                root.addChild(_bloodBar);
            }
            _bloodBar.sizeGrid = "8,8,8,8";
            _colliwidth = ConfigManager.getConfValue("cfg_anicollision", _aniName, "colliWidth6") as Number;
            _colliheight = ConfigManager.getConfValue("cfg_anicollision", _aniName, "colliHeight6") as Number;
            _colliOffsetX = ConfigManager.getConfValue("cfg_anicollision", _aniName, "colliOffsetX6") as Number;
            _colliOffsetY = ConfigManager.getConfValue("cfg_anicollision", _aniName, "colliOffsetY6") as Number;
            _bloodWith = ConfigManager.getConfValue("cfg_anicollision", _aniName, "bloodW") as Number;
            _bloodHeight = ConfigManager.getConfValue("cfg_anicollision", _aniName, "bloodH") as Number;
            _bloodOffsetX = ConfigManager.getConfValue("cfg_anicollision", _aniName, "bloodX") as Number;
            _bloodOffsetY = ConfigManager.getConfValue("cfg_anicollision", _aniName, "bloodY") as Number;
            _bloodBar.width = _bloodWith;
            _bloodBar.height = _bloodHeight;
            _bloodBar.visible = true;
            playAction(GameConst.action_sleep, true);
            _ani.visible = true;
            _isValid = true;
            _isActionDead = false;
            var id:Number = _id;
            if (id >= 5)
            {
                id -= 5;
                _bornPos.y = _initPos.y - _colliheight * Math.floor((_id + 1) / 5);
            } else
            {
                _bornPos.y = _initPos.y;
            }
            if (id == 2)
            {
                _bornPos.x = _initPos.x + _colliwidth * (id - 1);
            } else if (id == 3)
            {
                _bornPos.x = _initPos.x - _colliwidth * (id - 1);
            } else if (id == 0 || id == 1)
            {
                _bornPos.x = _initPos.x - _colliwidth * id;
            } else if (id == 4)
            {
                _bornPos.x = _initPos.x + _colliwidth * (id - 2);
            }
            _curPos.x = _bornPos.x;
            _curPos.y = _bornPos.y;
            updateRotation();
        }

        public function initBlood(full:Number):void
        {
            _fullBlood = full;
            _curBlood = full;
            _bloodBar.value = _curBlood / _fullBlood;
        }

        public function getHurt(hurt:Number):void
        {
            _curBlood -= hurt;
            if (_curBlood < 0)
            {
                _curBlood = 0;
            }
            _bloodBar.value = _curBlood / _fullBlood;
            if (_curBlood <= 0)
            {
                Laya.timer.once(200, this, playAction, [GameConst.action_dead, false, Handler.create(this, destroy)])
            }
        }

        public function getHurtAniPoint():Point
        {
            if (isValid() == false)
            {
                return null;
            }
            return new Point(_ani.x, _ani.y + _colliOffsetY);
        }

        public function playAction(type:Number, loop:Boolean = false, handler:Handler = null):void
        {
            if (type == GameConst.action_dead)
            {
                _isActionDead = true;
            }
            if (_aniType == GameConst.ani_type_skeleton)
            {
                var actionName:String = _aniActionInfo[type];
                (_ani as SpineTemplet).play(actionName, loop, handler);
            } else if (_aniType == GameConst.ani_type_frame)
            {

            }
        }


        override public function update(delta:Number):void
        {
            if (!isValid())
            {
                return
            }
            updateRotation();
        }

        private function updateRotation():void
        {
            _screenPos = CoordGm.instance.warTopoDesToScr(_curPos);
            _ani.pos(_screenPos.x, _screenPos.y);
            _ani.zOrder = _curPos.y;
            _bloodBar.zOrder = _curPos.y;
            _bloodBar.pos(_ani.x + _bloodOffsetX, _ani.y + _bloodOffsetY);
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
            _ani.visible = false;
            _bloodBar.visible = false;
            CachePool.Cache("Monster", null, this);
        }

        public function get ani():Sprite
        {
            return _ani;
        }

        public function get isActionDead():Boolean
        {
            return _isActionDead;
        }
    }
}