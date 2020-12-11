package fight
{
    import enums.FightType;

    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.utils.Handler;

    import manager.ConfigManager;

    import manager.SpineTemplet;

    public class SkillEffect extends FightBase
    {
        private var _ani:SpineTemplet;
        private var _aniName:String;
        private var _actionName:String;

        private var _designPos:Point;
        private var _screenPos:Point;
        public static var _skillEffectArr = [];

        public function SkillEffect():void
        {

        }

        public static function create(root:Sprite, aniName:String, deginPos:Point, upDown:Number, isDesignPos:Boolean = false):SkillEffect
        {
            var ret:SkillEffect = CachePool.GetCache("SkillEffect", "aniName", SkillEffect);
            ret.init(root, aniName, deginPos, upDown, isDesignPos);
            _skillEffectArr.push(ret);
            return ret;
        }

        private function init(root:Sprite, aniName:String, deginPos:Point, upDown:Number, isDesignPos:Boolean = false):void
        {
            _designPos = deginPos;
            _aniName = aniName;
            if (!_ani)
            {
                _ani = new SpineTemplet(aniName);
                root.addChild(_ani);
            }
            _ani.visible = false
            _actionName = ConfigManager.getConfValue("cfg_anicollision", _aniName, "actionName") as String;
            if (isDesignPos)
            {
                if (upDown == FightType.UP)
                {
                    _screenPos = CoordGm.instance.warTopoDesToScr(_designPos);
                } else if (upDown == FightType.DOWN)
                {
                    _screenPos = CoordGm.instance.zumaAllDesToScr(_designPos);
                }
            } else
            {
                _screenPos = _designPos;
            }
            _isValid = true;
            playAction()
        }

        private function playAction():void
        {
            _ani.pos(_screenPos.x, _screenPos.y);
            _ani.scale(1, 1);
            _ani.play(_actionName, false, Handler.create(this, actionComplete));
            _ani.visible = true;

        }

        private function actionComplete():void
        {
            destroy();
        }

        override public function update(delta:Number):void
        {

        }

        override public function isValid():Boolean
        {
            return _isValid;
        }

        override public function destroy():void
        {
            if (!isValid())
            {
                return
            }
            _ani.visible = false;
            _isValid = false;
            CachePool.Cache("SkillEffect", _aniName, this);
        }
    }
}
