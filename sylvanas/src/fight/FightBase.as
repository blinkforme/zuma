package fight
{
    import laya.maths.Rectangle;

    public class FightBase implements BaseInterface
    {
        protected var _isValid:Boolean;
        protected var _colliRect:Rectangle = new Rectangle();
        protected var _colliValid:Boolean = true;//碰撞是否生效
        public function FightBase()
        {
        }

        public function update(delta:Number):void
        {

        }

        public function isValid():Boolean
        {
            return _isValid;
        }

        public function destroy():void
        {

        }

        public function getColliRect():Rectangle
        {
            return _colliRect;
        }

        public function isCollision(target:FightBase):Boolean
        {
            if (!_colliValid)
            {
                return false;
            }
            return _colliRect.intersects(target.getColliRect());
        }

        public function isContainPoint(x, y):Boolean
        {
            return _colliRect.contains(x, y);
        }

        public function isThroughIn(x0:Number, y0:Number, x1:Number, y1:Number):Boolean
        {
            // 起始点在内部的情况剔除，防止被卡住
            if (_colliRect.contains(x0, y0))
            {
                return false;
            }
            return isContainPoint(x1, y1);
        }
    }
}