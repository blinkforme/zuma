package fight
{
    import fight.zuma.Ball;
    import fight.zuma.FireGun;
    import fight.zuma.ZumaMap;

    public class FightUpdate
    {

        private static var _removeArray:Array = [];

        private static function removeInvalidObjs(objs:Array, removeAll:Boolean = false):void
        {
            _removeArray.length = 0;
            var tmpBase:FightBase = null;
            var i:int = 0;
            var j:int = 0;
            var length:int = objs.length;
            var isRemove:Boolean = false;
            for (i = 0; i < length; i++)
            {
                isRemove = false;
                for (j = 0; j < objs.length; j++)
                {
                    tmpBase = objs[j];
                    if (!tmpBase.isValid() || removeAll)
                    {
                        isRemove = true;
                        objs.splice(j, 1);
                        tmpBase.destroy();
                        break;
                    }
                }
                if (!isRemove)
                {
                    return;
                }
            }
        }

        public static function updateObjs(objs:Array, delta):void
        {
            var i:int = 0;
            var tmpBase:FightBase = null;
            for (i = 0; i < objs.length; i++)
            {
                tmpBase = objs[i];
                tmpBase.update(delta);
            }
        }

        //状态更新
        public static function screenResize(delta):void
        {
            if (Monster._monsterArr && Monster._monsterArr.length > 0)
            {
                updateObjs(Monster._monsterArr, delta);
            }
        }

        //移除无效
        public static function removeObjs(removeAll:Boolean = false):void
        {
            //            removeInvalidObjs(Monster._monsterArr, true);
            removeInvalidObjs(SkillEffect._skillEffectArr, true);
            removeInvalidObjs(FireGun._activeBallQueue, true);
            removeInvalidObjs(Ball._ballArr, true);
            removeInvalidObjs(ZumaMap._roadblockArr, true);
        }
    }
}